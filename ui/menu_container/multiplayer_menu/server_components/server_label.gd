extends Control

var ip_address: String = "";

func _on_Join_button_up():
	var multiplayer_menu: Node = get_node("../../../../../../..");
	var lobby_menu: Node = multiplayer_menu.get_node("LobbyMenu");
	multiplayer_menu.get_node("ServerBrowser").queue_free();
	NetworkData.IP_ADDRESS = ip_address;
	NetworkData.create_client();
	GlobalData.change_visibility([lobby_menu], [true]);
