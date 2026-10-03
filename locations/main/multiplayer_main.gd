extends Node2D

signal RefreshMUI;

onready var mui: CanvasLayer = get_node("MultiplayerUI");
onready var spawn_positions = $SpawnPositions;
onready var camera = $Camera;
onready var sync_data_timer: Node = $Timers/SyncData;
onready var multiplayer_menu: Node = get_node("/root/GlobalTscn/MenuLayer/MultiplayerMenu");
onready var player_tscn: PackedScene = preload("res://characters/player/player.tscn");
onready var unix_time: float = 180.0;
onready var directional_light = $DirectionalLight;

var is_close: bool = false; var is_playing: bool = false;

var current_spawn_position: int = 1;
var current_player = null;

var qualified_players: Array = [];
var qualified_player: Node;

func _ready():
	directional_light.color = Color(GlobalData.settings_data["times_of_day"]["canvas_modulate"]);
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected");
	GlobalData.change_visibility([mui.cui, mui.tui], [false, false]); # Also hide the speedrun timer
	GlobalNodes.is_paused = true;
	if get_tree().is_network_server():
		attempt_to_configure();
	emit_signal("RefreshMUI");
	sync_data_timer.start();
	
	yield(GlobalTscn.transition_layer.get_node("TransitionAP"), "animation_finished");
	GlobalData.instantiate_node(load("res://ui/ui_none/single_player/init.tscn"), mui); # Start the countdown
	if get_tree().is_network_server():
		for child in GlobalNodes.get_children():
			child.rpc("start_vehicle_engine");
	yield(mui.get_node("Init/InitAP"), "animation_finished");
	GlobalNodes.is_paused = false; GlobalData.change_visibility([mui.cui, mui.tui], [true, true]); # Unleash the game
	is_playing = true;

func attempt_to_configure() -> void:
	for player in GlobalNodes.get_children():
		configure_player(player);
func configure_player(player: KinematicBody2D):
	for spawn_position in spawn_positions.get_children():
		if (spawn_position.name == "P%d" % current_spawn_position) and (current_player != player):
			printerr("%s's position was changed" % player.name);
			var data: Dictionary = {}; data["global_position"] = spawn_position.position; data["rotation"] = deg2rad(90);
			data["sprite"] = NetworkData.network_data[player.name]["sprite"]; data["mode"] = 1;
			data["headlights_color"] = NetworkData.network_data[player.name]["headlights_color"]; data["underglow_light_color"] = NetworkData.network_data[player.name]["underglow_light_color"];
			player.rpc("rpc_configure", data);
			current_spawn_position += 1;
			current_player = player;

func _physics_process(_delta):
	play();
func play() -> void:
	if not is_playing: return;
	if unix_time <= 60.0 and is_close == false:
		is_close = true; mui.speedrun_label.set("custom_colors/font_color", Color("d64040"));
		mui.speedrun_label.get_node("SpeedrunAP").play("zoom_in_out");
	if unix_time <= 0: # When the time is up, the ongoing quadrant is hacked
		rpc("show_result", NetworkData.network_data); return;
	unix_time -= get_physics_process_delta_time();

func _on_SyncData_timeout():
	var max_qualified_players: float = ceil(GlobalNodes.get_child_count() / 2.0);
	if GlobalNodes.get_child_count() == 1 and get_tree().is_network_server():
		GlobalTscn.change_scene_tree(load("res://ui/menu_container/main_menu/main_menu.tscn"), GlobalTscn.main_theme_id);
		multiplayer_menu.on_LobbyMenu_leave();
		GlobalTscn.clear_menu_layer();
		return;
	emit_signal("RefreshMUI");
	if qualified_players.size() >= max_qualified_players and get_tree().is_network_server():
		rpc("show_result", NetworkData.network_data);

func _on_FinishLine_body_entered(body: Node):
	if not body.is_in_group("player") or is_playing == false: return;
	qualified_player = body;
	rpc("qualify", qualified_player.name);
	var tween = create_tween();
	tween.tween_property(qualified_player, "engine_power", 0, 0.5);
remote func spectate() -> void:
	GlobalData.change_visibility([mui.cui], [false]);
sync func qualify(who: String) -> void:
	var max_qualified_players: float = ceil(GlobalNodes.get_child_count() / 2.0);
	if qualified_players.size() >= max_qualified_players: return;
	if not who in qualified_players:
		qualified_players.append(who);
	if qualified_players.size() < max_qualified_players:
		if GlobalNodes.get_node(who).is_network_master(): spectate();
		else: rpc_id(int(who), "spectate");

sync func show_result(network_data: Dictionary) -> void:
	sync_data_timer.stop(); is_playing = false; # Stops the speedrun timer
	GlobalNodes.is_paused = true; GlobalData.change_visibility([mui.cui, mui.tui], [false, false]); # Also hide the UI
	yield(get_tree().create_timer(2), "timeout");
	var result_menu = GlobalData.instantiate_node(load("res://ui/menu_container/multiplayer_menu/result_menu/result_menu.tscn"), GlobalTscn.get_node("MenuLayer"))
	result_menu.show_result(network_data, qualified_players, "Qualified" if GlobalData.master_player.name in qualified_players else "Eliminated");
func _on_network_peer_disconnected(id) -> void:
	if GlobalNodes.has_node(str(id)):
		GlobalNodes.get_node(str(id)).queue_free();
		qualified_players.erase(str(id));
