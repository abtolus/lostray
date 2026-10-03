extends Node

signal AddedServer;
signal RemovedServer;

onready var refresh_timer = $Refresh;

var socket_udp: PacketPeerUDP = PacketPeerUDP.new();
var listener_port = NetworkData.SERVER_PORT;
var available_servers: Dictionary = {};

func _ready():
	available_servers.clear();
	if socket_udp.listen(listener_port) != OK:
		print("ERROR while listening on port: " + str(listener_port));
	else:
		print("Listening on port: %s" % str(listener_port));

func _process(_delta):
	if socket_udp.get_available_packet_count() > 0:
		add_server();

func add_server() -> void:
	var server_ip = socket_udp.get_packet_ip();
	var server_port = socket_udp.get_packet_port();
	var bytes = socket_udp.get_packet();
	
	if server_ip != "" and server_port > 0:
		if not available_servers.has(server_ip):
			var server_message: String = bytes.get_string_from_ascii();
			var game_info = parse_json(server_message);
			game_info.ip = server_ip;
			game_info.last_seen = OS.get_unix_time();
			available_servers[server_ip] = game_info;
			emit_signal("AddedServer", game_info);
			printerr(socket_udp.get_packet_ip());
		else:
			var game_info = available_servers[server_ip];
			game_info.last_seen = OS.get_unix_time();

func remove_server(current_time, server_ip) -> void:
	var server_info = available_servers[server_ip];
	if (current_time - server_info.last_seen) > refresh_timer.wait_time:
		available_servers.erase(server_ip);
		emit_signal("RemovedServer", server_ip);

func _exit_tree():
	socket_udp.close();

func _on_Refresh_timeout():
	var current_time = OS.get_unix_time();
	for server_ip in available_servers:
		remove_server(current_time, server_ip);
