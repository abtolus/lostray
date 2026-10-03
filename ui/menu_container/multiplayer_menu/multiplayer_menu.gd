extends Control

onready var configuration = $Configuration;
onready var lobby_checklist = $LobbyMenu/HBC/Control/MC/VBC/SC/LobbyChecklist;
onready var lobby_menu = $LobbyMenu;

var player_tscn: PackedScene = load("res://characters/player/player.tscn");

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected");
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected");
	get_tree().connect("connected_to_server", self, "connect_to_server");

func _player_connected(id) -> void:
	register_player(id);
func _player_disconnected(id) -> void:
	if not GlobalNodes.has_node(str(id)):
		return;
	unregister_player(id);

func register_player(id: int) -> void:
	printerr("Player %s was registered" % str(id));
	lobby_menu.rpc_id(id, "register", PlayerData.personal_data); instantiate_player(id);
func unregister_player(id: int) -> void:
	printerr("Player %s was unregistered" % str(id));
	lobby_menu.call_deferred("unregister", str(id)); if GlobalNodes.has_node(str(id)): GlobalNodes.get_node(str(id)).queue_free();
func clear_data() -> void:
	for child in GlobalNodes.get_children(): child.queue_free();
	for child in lobby_checklist.get_children(): child.queue_free();
	var new_player_node: Node = get_tree().current_scene.get_node("Node2D").get_child(0).get_node("Path/Path2D/PathFollow2D");
	PlayerData.player_node = new_player_node;
	get_tree().current_scene.emit_signal("RefreshMainMenu");

func _on_CreateServer_button_up() -> void:
	NetworkData.create_server();
	GlobalData.change_visibility([lobby_menu], [true]);
	NetworkData.host_username = PlayerData.personal_data["name"];
	GlobalData.instantiate_node(load("res://ui/menu_container/multiplayer_menu/server_components/server_broadcaster.tscn"), self);
	lobby_menu.add_member(str(get_tree().get_network_unique_id()), PlayerData.personal_data);
	instantiate_player(get_tree().get_network_unique_id());
func _on_FindServers_button_up():
	GlobalData.instantiate_node(load("res://ui/menu_container/multiplayer_menu/server_browser/server_browser.tscn"), self);
func _on_ManualSetup_button_up() -> void:
	GlobalData.instantiate_node(load("res://ui/menu_container/multiplayer_menu/manual_setup/manual_setup.tscn"), self);

func on_LobbyMenu_leave() -> void:
	clear_data();
	get_tree().get_network_peer().close_connection();
	get_tree().network_peer = null;
	printerr("Refreshing the main menu!")

func connect_to_server() -> void:
	yield(get_tree().create_timer(0.1), "timeout");
	instantiate_player(get_tree().get_network_unique_id());

func add_camera(node: Node) -> void:
	var new_camera: Camera2D = Camera2D.new();
	new_camera.rotating = true;
	new_camera.current = true;
	new_camera.rotation_degrees = 90;
	node.add_child(new_camera);
func instantiate_player(id) -> void:
	var player: Object = GlobalData.instantiate_node(player_tscn, GlobalNodes);
	player.set_name(str(id));
	player.set_network_master(id);

func _on_Back_button_up():
	queue_free();
