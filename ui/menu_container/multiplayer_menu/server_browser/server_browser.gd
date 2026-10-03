extends Control

onready var public_servers = $MC/VBC/CR/SC/PublicServers;

func _ready():
	NetworkData.current_username = PlayerData.personal_data["name"];

func _on_ServerListener_AddedServer(server_info) -> void:
	var server_label_instance = GlobalData.instantiate_node(load("res://ui/menu_container/multiplayer_menu/server_components/server_label.tscn"), public_servers);
	server_label_instance.get_node("HBC/Label").text = "%s: %s " % [server_info.host_username, server_info.ip];
	server_label_instance.ip_address = str(server_info.ip);
func _on_ServerListener_RemovedServer(server_ip) -> void:
	for server_node in public_servers.get_children():
		if server_node.is_in_group("server_label") and server_node.ip_address == server_ip:
			server_node.queue_free();
			break;

func _on_Back_button_up():
	queue_free();
