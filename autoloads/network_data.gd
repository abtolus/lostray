extends Node

const SERVER_PORT: int = 28961;
const MAX_PLAYERS: int = 6;

var host: NetworkedMultiplayerENet = null; var client: NetworkedMultiplayerENet = null; var IP_ADDRESS: String = "";
var host_username: String = ""; var current_username: String = "";
var network_data: Dictionary = {};
var network_status: int = -1;

#var socket_tcp: StreamPeerTCP; var is_connected_to_host: bool; var ping: int = 1;

func _ready():
	get_tree().connect("connected_to_server", self, "connect_to_server");
	get_tree().connect("server_disconnected", self, "disconnect_from_server");
	get_tree().connect("connection_failed", self, "_connection_failed");
	get_tree().set_network_peer(null);
	match OS.get_name():
		"Window": IP_ADDRESS = IP.get_local_addresses()[3];
		"Android": IP_ADDRESS = IP.get_local_addresses()[0];
		_: IP_ADDRESS = IP.get_local_addresses()[3];
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") and not ip.ends_with(".1"):
			IP_ADDRESS = ip;

#	socket_tcp = StreamPeerTCP.new();
#	socket_tcp.set_no_delay(true);
#	socket_tcp.connect_to_host("8.8.8.8", 53);

#func has_network_connection():
#	if is_connected_to_host == false:
#		socket_tcp = StreamPeerTCP.new();
#		socket_tcp.connect_to_host("8.8.8.8", 53);
#		is_connected_to_host = true;
#		return true;
#	return (get_network_connection() and ping <= 4);
#func get_network_connection() -> bool:
#	var status: bool;
#	match socket_tcp.get_status():
#		0:
#			status = true;
#			is_connected_to_host = false;
#		1:
#			printerr("Connecting");
#			status = true;
#			ping += 1;
#		2:
#			printerr("Has connected");
#			status = true;
#			ping = 1;
#	return status;

func create_server() -> void:
	host = NetworkedMultiplayerENet.new()
	host.create_server(SERVER_PORT, MAX_PLAYERS);
	get_tree().set_network_peer(host);
func create_client() -> void:
	client = NetworkedMultiplayerENet.new();
	client.create_client(IP_ADDRESS, SERVER_PORT);
	get_tree().set_network_peer(client);
func reset_network() -> void:
	if get_tree().has_network_peer():
		get_tree().network_peer = null;

func connect_to_server() -> void:
	printerr("Successfully connected to the server");
func disconnect_from_server() -> void:
	print("Disconnected from the server");
	for child in GlobalNodes.get_children():
		child.queue_free();
	reset_network();
	var string: String = "The server was completely shut down by the host";
	var prompt: Node = load("res://ui/ui_all/multiplayer/prompt.tscn").instance();
	prompt.mode = 1; prompt.set_text(string);
	GlobalTscn.load_menu(prompt);
func _connection_failed() -> void:
	print("Connection failed");
	for child in GlobalNodes.get_children():
		child.queue_free();
	reset_network();
	var string: String = "Connection lost while connecting to the server";
	var prompt: Node = load("res://ui/ui_all/prompt.tscn").instance();
	prompt.mode = 1; prompt.set_text(string);
	GlobalTscn.load_menu(prompt)
