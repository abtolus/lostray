extends Control

onready var to_lobby_timer: Node = $ToLobby;
onready var lobby_label = $C/MC/VBC/HBC/LobbyLabel;
onready var multiplayer_menu: Node = get_node("/root/GlobalTscn/MenuLayer/MultiplayerMenu");

func _ready(): lobby_label.set_text("Lobby %s" % str(to_lobby_timer.wait_time));
func _physics_process(_delta):
	lobby_label.set_text("Lobby %s" % str(ceil(to_lobby_timer.time_left)));

func show_result(network_data: Dictionary, qualified_players: Array, result_title_text: String = "ERROR") -> void:
	var result_title = $C/MC/VBC/ResultTitle; var vbc = $C/MC/VBC/C/VBC;
	result_title.set_text(result_title_text);
	result_title.set("custom_colors/font_color", Color("a0a0ff") if result_title_text == "Qualified" else Color("ffa0a0"))
	for qualified_player in qualified_players:
		var result_label = load("res://ui/menu_container/multiplayer_menu/result_menu/result_label.tscn").instance();
		result_label.get_node("Label").text = network_data[qualified_player]["name"]; vbc.add_child(result_label)
	to_lobby_timer.start();

func _on_ToLobby_timeout():
	GlobalTscn.change_scene_tree(load("res://ui/menu_container/main_menu/main_menu.tscn"), GlobalTscn.main_theme_id);
	var mode_selection_menu: Node = multiplayer_menu.get_parent().get_node("ModeSelectionMenu");
	yield(get_tree().create_timer(0.5), "timeout");
	GlobalData.change_visibility([multiplayer_menu, mode_selection_menu], [true, true]);
	if get_tree().is_network_server(): GlobalData.instantiate_node(load("res://ui/menu_container/multiplayer_menu/server_components/server_broadcaster.tscn"), multiplayer_menu);
	queue_free();

func _on_MainMenu_button_up():
	GlobalTscn.change_scene_tree(load("res://ui/menu_container/main_menu/main_menu.tscn"), GlobalTscn.main_theme_id);
	multiplayer_menu.on_LobbyMenu_leave();
	GlobalTscn.clear_menu_layer();
