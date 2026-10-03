extends Control

onready var multiplayer_menu: Node = $"..";
onready var lobby_checklist = $HBC/Control/MC/VBC/SC/LobbyChecklist;
onready var lobby_label_tscn: PackedScene = load("res://ui/menu_container/multiplayer_menu/lobby_menu/lobby_label.tscn");
onready var start_button: Node = $HBC/Control/MC/VBC/Control/Start;
onready var server_ip_address_label: Node = $CR2/IPL;

func _physics_process(_delta):
	if GlobalNodes.get_child_count() < 2: start_button.disabled = true;
	else: start_button.disabled = false;

remotesync func register(personal_data: Dictionary) -> void:
	var remote_id: String = str(get_tree().get_rpc_sender_id());
	add_member(remote_id, personal_data);
func unregister(id: String) -> void:
	remove_member(id);

func add_member(id: String, data: Dictionary) -> void:
	var lobby_label = GlobalData.instantiate_node(lobby_label_tscn, lobby_checklist);
	lobby_label.set_name(id);
	lobby_label.get_node("MC/HBC/C/Name").text = "%s :" % data["name"];
	lobby_label.get_node("MC/HBC/C/ID").text = "%s" % id;
	var texture: StreamTexture = load("res://assets/images/sprites/%s.png" % data["sprite"])
	lobby_label.get_node("MC/HBC/C2/Sprite").set_texture(texture);
	NetworkData.network_data[id] = data;
func remove_member(id: String) -> void:
	if lobby_checklist.has_node(id):
		lobby_checklist.get_node(id).queue_free();
		NetworkData.network_data.erase(id)

func _on_Start_button_up():
	multiplayer_menu.get_node("ServerBroadcaster").queue_free();
	rpc("attempt_to_change_scene_tree");
remotesync func attempt_to_change_scene_tree() -> void:
	var mode_selection_menu: Node = multiplayer_menu.get_parent().get_node("ModeSelectionMenu");
	GlobalData.change_visibility([multiplayer_menu, mode_selection_menu], [false, false]);
	GlobalTscn.change_scene_tree(load("res://locations/rainforest/multiplayer_rainforest.tscn"), GlobalTscn.last_bastion_id);
func _on_Leave_button_up():
	hide();
	get_parent().on_LobbyMenu_leave();

func _on_LobbyMenu_visibility_changed():
	if visible == false:
		return;
	server_ip_address_label.set_text(NetworkData.IP_ADDRESS);
	start_button.visible = true if get_tree().is_network_server() else false;
