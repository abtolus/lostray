extends Control

onready var garage_submenu = $HBC/GarageSubmenu/MC/VBC;
onready var coins_label: Label = $CR2/HBoxContainer/CoinsLabel;
onready var tab_container = $HBC/Control/TabContainer;

var garage_texture_: Node;
var item_data_: Dictionary;

var MODE: int = 0;
var current_tab_index: int = 0;

func is_unlocked(data: Dictionary):
	match current_tab_index:
		0, 1, 2:return GlobalData.garage_data[data["id"]]["unlocked"]
func unlock(is_unlocked: bool = true, data: Dictionary = item_data_) -> void:
	match current_tab_index:
		0, 1, 2:GlobalData.garage_data[data["id"]]["unlocked"] = is_unlocked;
func _ready():
	tab_container.set_tab_title(0, " Vehicles ");
	tab_container.set_tab_title(1, " Headlights ");
	tab_container.set_tab_title(2, " Underglow Lights ");
	get_tree().current_scene.connect("RefreshMainMenu", self, "refresh_garage_menu");
	get_node("HBC/GarageSubmenu").visible = false; _load();
	get_tree().current_scene.emit_signal("RefreshMainMenu");

func refresh_garage_menu() -> void:
	coins_label.set_text("%s" % GlobalData.get_formatted_coins(PlayerData.personal_data["coins"]));

func _load(tab_index: int = 0) -> void:
	var gc: GridContainer = get_node("HBC/Control/TabContainer/SC%d/Control/MC/GC" % tab_index);
	for child in gc.get_children(): child.queue_free();
	for key in GlobalData.garage_data.keys():
		if tab_index == 0 and GlobalData.garage_data[key].has("hex"): continue;
		if tab_index == 1 and not GlobalData.garage_data[key]["category"] == "headlights": continue;
		if tab_index == 2 and not GlobalData.garage_data[key]["category"] == "underglow_light": continue;
		var garage_texture: Object = GlobalData.instantiate_node(load("res://ui/menu_container/garage_menu/garage_texture.tscn"), gc);
		var item_data: Dictionary = {};
		item_data["id"] = key; item_data["value"] = GlobalData.garage_data[key];
		garage_texture.garage_menu = self; garage_texture.item_data_ = item_data;
		garage_texture.load_garage_texture();
		if GlobalData.garage_data[key].has("hex"):
			var item_color: String = "%s" % GlobalData.garage_data[key]["hex"]; garage_texture.get_node("CR").color = item_color;
			if tab_index == 1:
				var headlight_texture: StreamTexture = load("res://assets/images/sprites/headlight_icon.png")
				garage_texture.get_node("CR/TextureRect").set_texture(headlight_texture);
			elif tab_index ==2:
				var underglow_light_texture: StreamTexture = load("res://assets/images/sprites/underglow_light_icon.png")
				garage_texture.get_node("CR/TextureRect").set_texture(underglow_light_texture);
			else: pass;
			garage_texture.get_node("CR").visible = true; garage_texture.get_node("TR").visible = false;
		else:
			var item_icon: StreamTexture = load("res://assets/images/sprites/%s.png" % GlobalData.garage_data[key]["id"]);
			garage_texture.get_node("TR").set_texture(item_icon);
			garage_texture.get_node("TR").visible = true; garage_texture.get_node("CR").visible = false;

func _on_Button_button_up():
	match MODE:
		0: 
			var required: float = GlobalData.garage_data[item_data_["id"]]["prerequisites"]["coins"];
			if PlayerData.personal_data["coins"] < required: return;
			PlayerData.personal_data["coins"] -= required;
			unlock(); # Unlock whatever it is
			garage_texture_.load_garage_texture(); garage_texture_.attempt_to_select();
			get_tree().current_scene.emit_signal("RefreshMainMenu");
		1: configure_player();

func configure_player() -> void:
	match current_tab_index:
		0: PlayerData.change_sprite(item_data_["value"]["id"]);
		1: PlayerData.change_headlights(item_data_["value"]["hex"]);
		2: PlayerData.change_underglow_light(item_data_["value"]["hex"]);
func _on_Back_button_up(): queue_free();


func _on_TabContainer_tab_selected(tab):
	current_tab_index = tab;
	_load(tab);
