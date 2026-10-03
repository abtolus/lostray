class_name Main
extends Node2D

signal RefreshUI;
signal RefreshMain;

onready var control_devices = $ControlDevices;
onready var single_player_camera = $SinglePlayerCamera;
onready var directional_light: CanvasModulate = $DirectionalLight;
onready var ui: Node = get_node("UI");
onready var unix_time: float = get_unix_time_by_difficulty(GlobalData.settings_data["difficulty"]["value"]);

const audio_id: String = "res://assets/audio/music/Kaustunt - Phonky Frog.mp3";

var MODE: int = -1; var total_coins: float = 0;
var is_playing: bool = false; var is_close: bool = false;
var finished_quadrants: Dictionary = {}; var hacked_quadrants: Dictionary = {};
var on_quadrant: Node = null;

func _ready():
	connect("RefreshMain", self, "refresh");
	directional_light.color = Color(GlobalData.settings_data["times_of_day"]["canvas_modulate"]);
	if get_tree().current_scene.name == "MainMenu":
		get_node("../..").main = self;
		return;
	
	GlobalData.change_visibility([ui.cui, ui.tui], [false, false]); # Also hide the speedrun timer
	GlobalNodes.is_paused = true; PlayerData.user_data["last_main"] = self.name.to_lower();
	randomize();
	for quadrant in control_devices.get_children():
		if quadrant is Node2D:
			generate_control_devices(quadrant);
	instantiate_player(); emit_signal("RefreshUI");
	on_Challenge_ready(); emit_signal("RefreshMain");
	
	yield(GlobalTscn.get_node("TransitionLayer/TransitionAP"), "animation_finished");
	GlobalData.instantiate_node(load("res://ui/ui_none/single_player/init.tscn"), ui); # Start the countdown
	# START THE ENGINE
	PlayerData.player_node.start_vehicle_engine();
	yield(ui.get_node("Init/InitAP"), "animation_finished")
	GlobalNodes.is_paused = false; GlobalData.change_visibility([ui.cui, ui.tui], [true, true]); # Unleash the game

func generate_control_devices(quadrant: Node) -> void:
	var transmitters: Array = [
		"res://control_devices/transmitters/additon/additon.tscn", "res://control_devices/transmitters/cameran/cameran.tscn", "res://control_devices/transmitters/clowork/clowork.tscn", "res://control_devices/transmitters/kimatic/kimatic.tscn",
		"res://control_devices/transmitters/logaite/logaite.tscn", "res://control_devices/transmitters/mathics/mathics.tscn", "res://control_devices/transmitters/parkrea/parkrea.tscn", "res://control_devices/transmitters/secault/secault.tscn"];
	for p in quadrant.get_children():
		if p is Position2D:
			var random_index: int = randi() % transmitters.size();
			var transmitter_instance: Object = load(transmitters[random_index]).instance();
			transmitter_instance.global_position = p.global_position;
			transmitter_instance.global_rotation = p.global_rotation;
			transmitter_instance.rotation = p.rotation;
			quadrant.add_child(transmitter_instance);
			transmitters.erase(transmitters[random_index]);
func instantiate_player() -> void:
	var player = GlobalData.instantiate_node(load("res://characters/player/player.tscn"), GlobalNodes);
	player.global_rotation = get_random_rotation(); player.main = self; MODE = PlayerData.MODE;
	player.get_node("Sprite").set_texture(load("res://assets/images/sprites/%s.png" % PlayerData.personal_data["sprite"]));
# The Challenge Mode
func on_Challenge_ready() -> void:
	match PlayerData.MODE:
		2: get_node("Environment/CollisionLayer").modulate = Color("df2629");
		3: single_player_camera.camera_rotation_speed = GlobalData.settings_data["camera_rotation_speed"]["value"] / 2.5;
		5: GlobalNodes.get_node("Player").specifications.grip = 0.1;

func get_random_rotation() -> float:
	var array: Array = [0, 90, 180, -90];
	return deg2rad(array[randi() % array.size()])

func restart() -> void:
	ui.speedrun_label.set("custom_colors/font_color", Color("d6d6ff"));
	is_close = false; # Make the speedrun timer refresh
	PlayerData.player_node.database = []; unix_time = get_unix_time_by_difficulty(GlobalData.settings_data["difficulty"]["value"]);
	emit_signal("RefreshMain"); emit_signal("RefreshUI");
	
	var tween: SceneTreeTween = create_tween();
	PlayerData.player_node.global_position = Vector2.ZERO;
	yield(tween.tween_property(PlayerData.player_node, "global_rotation", get_random_rotation(), 1.0), "finished");
	
	GlobalData.instantiate_node(load("res://ui/ui_none/single_player/init.tscn"), ui);
	# RESTART THE ENGINE
	PlayerData.player_node.start_vehicle_engine();
	yield(ui.get_node("Init/InitAP"), "animation_finished")
	GlobalData.change_visibility([ui.cui, ui.tui], [true, true]);
	GlobalNodes.is_paused = false; # Unleash the game
func start(quadrant: Node) -> void:
	on_quadrant = quadrant;
	for child in control_devices.get_children():
		if not child == quadrant and child.is_in_group("quadrant"):
			_manage(child);
	is_playing = true; # Start the speedrun timer
	ui.speedrun_label.set("custom_colors/font_color", Color("d6d6ff"));
	ui.speedrun_label.get_node("SpeedrunAP").play("zoom_in_out");
	yield(ui.speedrun_label.get_node("SpeedrunAP"), "animation_finished");

func refresh() -> void:
	for child in control_devices.get_children():
		if child.is_in_group("quadrant") and child is Node2D:
			refresh_quadrant(child);
func refresh_quadrant(child: Node) -> void:
	if child.name.to_lower() in finished_quadrants:
		_manage(child); _clear(child);
	elif child.name.to_lower() in hacked_quadrants:
		_manage(child); _clear(child);
	else: _manage(child, true);
func _clear(node: Node) -> void:
	for child in node.get_children():
		if not child is Position2D and child.is_in_group("transmitter"):
			child.queue_free();
func _manage(quadrant: Node, unlocked: bool = false) -> void:
	for child in quadrant.get_children():
		if child.is_in_group("electric_door"):
			child.get_node("Panel").visible = unlocked;
			child.unlocked = unlocked;
			child.visible = true;

func _physics_process(_delta):
	play();
func play() -> void:
	if not is_playing: return;
	if unix_time <= 60.0 and is_close == false:
		is_close = true; ui.speedrun_label.set("custom_colors/font_color", Color("d64040"));
		ui.speedrun_label.get_node("SpeedrunAP").play("zoom_in_out");
	if unix_time <= 0: # When the time is up, the ongoing quadrant is hacked
		is_playing = false;
		hack_quadrant(); return;
	unix_time -= get_physics_process_delta_time();

func hack_quadrant() -> void:
	if GlobalTscn.has_node("MenuLayer/TabletMenu"):
		GlobalTscn.get_node("MenuLayer/TabletMenu").queue_free();
	hacked_quadrants[on_quadrant.name.to_lower()] = {"name": on_quadrant.name, "unix_time": unix_time, "coins": get_coins(unix_time, PlayerData.player_node.database)};
	total_coins += get_coins(unix_time, PlayerData.player_node.database);
	load_result_menu(["Quadrant Hacked", "ff2020"]);
# Calls everytime the quadrant is finished
func finish_quadrant() -> void:
	finished_quadrants[on_quadrant.name.to_lower()] = {"name": on_quadrant.name, "unix_time": unix_time, "coins": get_coins(unix_time, PlayerData.player_node.database)};
	total_coins += get_coins(unix_time, PlayerData.player_node.database);
	load_result_menu(["Quadrant Finished", "2020ff"]);
# Prerequisites [title_text, title_color]
func load_result_menu(prerequisites: Array) -> void:
	GlobalData.change_visibility([ui.cui, ui.tui], [false, false]); # Also hide the speedrun timer
	var result_menu = GlobalData.instantiate_node(load("res://ui/menu_container/single_player_menu/result_menu/result_menu.tscn"), GlobalTscn.get_node("MenuLayer"));
	result_menu.main = self;
	result_menu._load(prerequisites);
func get_coins(unix_time_: float, database: Array) -> float:
	var max_unix_time: float = get_unix_time_by_difficulty(GlobalData.settings_data["difficulty"]["value"]);
	unix_time_ = max(0.0, unix_time_);
	var count: int = database.size();
	var first: float = ((count / 8.0) * (count * PI) * PI);
	var second: float = ((unix_time_ / max_unix_time) * PI)
	return abs(ceil((first * second) * 0.5));

func get_unix_time_by_difficulty(text: String) -> float:
	match text:
		"Easy": return 300.0; "Normal": return 240.0; "Default": return 180.0;
		"Hard": return 120.0; "Insane": return 90.0; _: return 300.0;
