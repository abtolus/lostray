extends ColorRect

var item_data_: Dictionary;
var garage_menu: Node;

func load_garage_texture() -> void:
	color = Color("303649") if garage_menu.is_unlocked(item_data_) else Color("303639");

func _on_GarageTexture_gui_input(event):
	if event is InputEventScreenTouch and event.pressed:
		if not garage_menu.is_unlocked(item_data_):
			attempt_to_unlock(); color = Color("404649");
			return;
		attempt_to_select(); color = Color("404659");
	elif event is InputEventScreenTouch and not event.pressed:
		var garage_submenu: Node = garage_menu.get_node("HBC/GarageSubmenu");
		if garage_submenu.visible == false: garage_submenu.visible = true;
		if not garage_menu.is_unlocked(item_data_):
			color = Color("303639");
			return;
		color = Color("303649");

func attempt_to_unlock() -> void:
	garage_menu.MODE = 0;
	load_garage_submenu();

func attempt_to_select() -> void:
	garage_menu.MODE = 1;
	load_garage_submenu();

func load_garage_submenu() -> void:
	garage_menu.item_data_ = item_data_; garage_menu.garage_texture_ = self;
	var texture_node: Node = garage_menu.garage_submenu.get_node("Control/VBC/TR/CR/TR"); var color_node: ColorRect = garage_menu.garage_submenu.get_node("Control/VBC/TR/CR/CR");
	if item_data_["value"].has("hex"):
		if garage_menu.current_tab_index != 0:
			color_node.color = item_data_["value"]["hex"];
			color_node.visible = true; texture_node.visible = false;
	else:
		var texture: StreamTexture = load("res://assets/images/sprites/%s.png" % item_data_["value"].id);
		texture_node.set_texture(texture);
		texture_node.visible = true; color_node.visible = false;
	var label_node: Node = garage_menu.garage_submenu.get_node("Control/VBC/Label");
	var label: String = GlobalData.garage_data[item_data_["id"]].name;
	label_node.set_text(str(label));
	var button_node: Node = garage_menu.garage_submenu.get_node("Button");
	button_node.set_text("Select" if garage_menu.MODE == 1 else "Unlock");

	var hbc: HBoxContainer = garage_menu.garage_submenu.get_node("Control/VBC/HBoxContainer");
	var prerequisite_label: Label = hbc.get_node("CoinsLabel");
	hbc.visible = false; 
	var has_prerequisites: bool = GlobalData.garage_data[item_data_["id"]].has("prerequisites") and not garage_menu.is_unlocked(item_data_);
	if has_prerequisites == false: return;
	var required: float = GlobalData.garage_data[item_data_["id"]]["prerequisites"]["coins"];
	var available: float = PlayerData.personal_data["coins"];
	prerequisite_label.set_text("%s/%s" % [GlobalData.get_formatted_coins(available), GlobalData.get_formatted_coins(required)]); hbc.visible = true;
	var color: Color = Color("40d640") if available >= required else Color("d6d6ff");
	prerequisite_label.set("custom_colors/font_color", color);
#	prerequisite_node.visible = false;
#	if has_prerequisite == true:
#		prerequisite_node.set_text(str("Requirements"));
#		prerequisite_node.visible = true;
