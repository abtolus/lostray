extends Control

onready var active_amount_label: Node = $VBC/AHBC/C/MC/HBC/ActiveAmount;
onready var qualified_amount_label: Node = $VBC/QHBC/C/MC/HBC/QualifiedAmount;
onready var multiplayer_main: Node = get_node("../../..");
onready var multiplayer_menu: Node = get_node("/root/GlobalTscn/MenuLayer/MultiplayerMenu");

func refresh() -> void:
	var max_qualified_players: float = ceil(GlobalNodes.get_child_count() / 2.0);
	active_amount_label.set_text(str(GlobalNodes.get_child_count()));
	qualified_amount_label.set_text("%s/%s" % [str(multiplayer_main.qualified_players.size()), str(max_qualified_players)])

func _on_Leave_button_up():
	GlobalTscn.change_scene_tree(load("res://ui/menu_container/main_menu/main_menu.tscn"), GlobalTscn.main_theme_id);
	multiplayer_menu.on_LobbyMenu_leave();
	GlobalTscn.clear_menu_layer();
