extends Control

onready var lobby_menu: Node = get_node("../LobbyMenu");
onready var server_ip_address_line_edit: Node = $Control/MC/VBC/ServerIpAddress;

func _ready():
	server_ip_address_line_edit.set_text("192.168.");

func _on_Join_button_up():
	if server_ip_address_line_edit.text == "" or not server_ip_address_line_edit.text.begins_with("192.168."):
		return;
	GlobalData.change_visibility([lobby_menu], [true]);
	NetworkData.IP_ADDRESS = server_ip_address_line_edit.text;
	NetworkData.create_client();
	queue_free();
func _on_ExitSetup_button_up():
	queue_free();
