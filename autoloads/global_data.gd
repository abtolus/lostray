extends Node

var global_data_tres: Resource;
var garage_data: Dictionary;
var settings_data: Dictionary = {};
var challenge_data: Dictionary = {};

var today_challenge_data: Dictionary;
var global_data_tres_path: String = "user://global_data_tres";
var master_player = null;

var files: Array = ["garage_data.json", "player_data_tres.tres", "signup.json"]

func _ready():
	garage_data = get_data("garage_data.json")
	load_data();
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(settings_data["music_volume"] / 100.0));
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound effects"), linear2db(settings_data["sound_effects_volume"] / 100.0))

func clear_data() -> void:
	var dir = Directory.new();
	for file_path in files:
		var full_path = "user://" + file_path
		if dir.file_exists(full_path):
			var error = dir.remove(full_path);
			if error != OK: print("Unable to remove the file: ", file_path);
	PlayerData.player_data_tres = null;
	garage_data = get_data("garage_data.json");
	save_data();

func lerp_angle(from, to, weight: float = settings_data["camera_rotation_speed"]["value"]): return from + short_angle_distance(from, to) * (get_process_delta_time() * weight);
func short_angle_distance(from, to):
	var max_angle = PI * 2;
	var difference = fmod(to - from, max_angle); return fmod(2 * difference, max_angle) - difference

func change_visibility(nodes: Array, bools: Array) -> void:
	for index in range(nodes.size()):
		nodes[index].visible = bools[index];
func instantiate_node(node: Object, parent: Object) -> Object:
	var node_instance: Node = node.instance();
	parent.add_child(node_instance);
	return node_instance;
# 21600
func has_passed(between_unix: float, ISO: int = 0):
	match ISO:
		0: return true if between_unix >= 60 else false;
		1: return true if between_unix >= 86400 else false;
		2: return true if between_unix >= 2635200 else false;
		3: return true if between_unix >= 31622400 else false;
		_: printerr("Invalid ISO - has_passed() - global_data")

func get_data(file_: String) -> Dictionary:
	var file: File = File.new();
	var res_path: String = "res://assets/json/%s" % [file_];
	var user_path: String = "user://%s" % [file_];
	if file.file_exists(user_path):
		file.open(user_path, File.READ);
		var json_data = file.get_as_text();
		var data: Dictionary = parse_json(json_data);
		file.close();
		return data;
	else: return create_data(res_path, user_path);
func create_data(res_path: String, user_path: String) -> Dictionary:
	var original_file: File = File.new(); var duplicated_file: File = File.new();
	if original_file.open(res_path, File.READ) != OK:
		prints("ERROR while reading the file at path " + res_path);
		return {};
	var json_data = original_file.get_as_text();
	original_file.close();
	if duplicated_file.open(user_path, File.WRITE) != OK:
		prints("ERROR while writing the file at path " + user_path);
		return {};
	duplicated_file.store_line(json_data);
	duplicated_file.close();
	var data: Dictionary = parse_json(json_data);
	return data;
func set_data(data: Dictionary, path: String) -> void:
	var json_data = JSON.print(data, "\t"); # Turns the dictionary into the formatted JSON (pretty printing)
	var file: File = File.new();
	var error = file.open(path, File.WRITE);
	if error != OK:
		print_debug("ERROR whild writing the file at path: %s" % [path]);
		return;
	file.store_string(json_data);
	file.close();
func get_time(unix_time: float) -> String:
	unix_time = max(0.0, unix_time);
	var minutes: float = floor(unix_time / 60.0);
	var seconds: float = unix_time - (minutes * 60);
	return "%02d:%05.2f" % [minutes, seconds];

func get_formatted_coins(coins: float) -> String:
	if coins >= 1000.0: return "%04.2fK" % [coins / 1000.0];
	elif coins >= 1000000.0: return "%04.2fM" % [coins / 1000000.0];
	elif coins >= 1000000000.0: return "%04.2fB" % [coins / 1000000000.0];
	else: return str(coins);

func load_data() -> void:
	if GlobalDataTres.data_exists(global_data_tres_path):
		global_data_tres = GlobalDataTres.load_data(global_data_tres_path) as GlobalDataTres;
	else:
		global_data_tres = GlobalDataTres.new();
		global_data_tres.save_data(global_data_tres_path);
	settings_data = global_data_tres.static_global_data["settings_data"];
	challenge_data = global_data_tres.static_global_data["challenge_data"];

func save_data() -> void:
	global_data_tres.static_global_data["settings_data"].merge(settings_data, true);
	global_data_tres.save_data(global_data_tres_path);
	set_data(garage_data, "user://garage_data.json");
