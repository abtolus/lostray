extends Node

onready var refresh_timer = $Refresh

var server_info: Dictionary = {"host_username": ""};
var socket_udp: PacketPeerUDP;
var broadcaster_port = NetworkData.SERVER_PORT;

func _enter_tree():
	if get_tree().is_network_server():
		socket_udp = PacketPeerUDP.new();
		socket_udp.set_broadcast_enabled(true);
		socket_udp.set_dest_address("255.255.255.255", broadcaster_port);

func _exit_tree():
	refresh_timer.stop();
	if socket_udp != null:
		socket_udp.close();

func _on_Refresh_timeout():
	server_info.host_username = NetworkData.network_data["1"]["name"];
	var packet_message = to_json(server_info);
	var packet = packet_message.to_ascii();
	socket_udp.put_packet(packet);
