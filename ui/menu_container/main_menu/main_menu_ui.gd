extends Control

onready var main_menu: Node2D = get_node("../..");
onready var username_edition: Control = $UsernameEdition;
onready var cancel_button: Button = $UsernameEdition/Control/MC/VBC/HBC/Cancel;
onready var coins_label: Label = $TControl/HBoxContainer/CoinsLabel;

onready var username_line_edit: LineEdit = $UsernameEdition/Control/MC/VBC/LineEdit;
onready var edit_username_button: Button = $TControl/EditUsername;

onready var supabase_menu_tscn: PackedScene = preload("res://ui/menu_container/supabase_menu/supabase_menu.tscn")

func _ready():
	get_node("../..").connect("RefreshMainMenu", self, "refresh_main_menu");
	username_edition.visible = false;
	refresh();

func refresh_main_menu() -> void:
	PlayerData.change_sprite(PlayerData.personal_data["sprite"]); PlayerData.change_headlights(PlayerData.personal_data["headlights_color"]);
	PlayerData.change_underglow_light(PlayerData.personal_data["underglow_light_color"]); PlayerData.set_times_of_day(GlobalData.settings_data["times_of_day"]);
	
	edit_username_button.text = PlayerData.personal_data["name"];
	coins_label.set_text("%s" % GlobalData.get_formatted_coins(PlayerData.personal_data["coins"]));
	var directional_light: CanvasModulate = main_menu.main.get_node("DirectionalLight");
	directional_light.color = Color(GlobalData.settings_data["times_of_day"]["canvas_modulate"]);
func refresh() -> void:
	edit_username_button.text = PlayerData.personal_data["name"];

func _on_Drive_button_up():
	GlobalTscn.load_menu(load("res://ui/menu_container/mode_selection_menu/mode_selection_menu.tscn").instance());
func _on_Garage_button_up():
	GlobalTscn.load_menu(load("res://ui/menu_container/garage_menu/garage_menu.tscn").instance());
func _on_Settings_button_up():
	GlobalTscn.load_menu(load("res://ui/menu_container/settings_menu/settings_menu.tscn").instance());
func _on_Quit_button_up():
	get_tree().quit();

func _on_Cancel_button_up():
	username_edition.visible = false;
	username_line_edit.clear();
func _on_Confirm_button_up():
	if username_line_edit.text == "" or len(username_line_edit.text) < 4:
		return;
	PlayerData.personal_data["name"] = username_line_edit.text;
	username_edition.visible = false;
	username_line_edit.clear();
	refresh();
func _on_EditUsername_button_up():
	username_edition.visible = true;
	cancel_button.visible = true;

func _on_WatchCredtis_button_up():
	var _credits_menu: Object = GlobalData.instantiate_node(load("res://ui/menu_container/main_menu/credits_menu/credits_menu.tscn"), GlobalTscn.menu_layer);

func _on_SupabaseTR_button_up():
	get_parent().add_child(supabase_menu_tscn.instance());
