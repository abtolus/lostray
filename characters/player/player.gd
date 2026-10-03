class_name Player
extends KinematicBody2D

onready var vehicle_engine_asp: AudioStreamPlayer = $SoundEffects/VehicleEngineASP;
onready var friction_asp: AudioStreamPlayer = $SoundEffects/FrictionASP;

onready var trail_node = $Trail; onready var tween = $Tween;
onready var main: Node;

var trail_tscn: PackedScene = preload("res://characters/player/trail.tscn");
var specifications: Dictionary = {
	"wheel_base": 112, "steering_angle": 56.0,
	"friction": -0.96, "drag": -0.0064, "grip": 0.75
};
var engine_power: int = 0; var velocity: Vector2 = Vector2.ZERO;
var direction: float = 0.0; var acceleration: Vector2 = Vector2.ZERO;
var turn: int = 0;

var control_device: Node; var control_devices: Array = [];
var database: Array = [];

puppet var puppet_global_position: Vector2 = Vector2(0, 0) setget set_puppet_global_position;
puppet var puppet_velocity: Vector2 = Vector2(); puppet var puppet_rotation: float = 0;

func set_puppet_global_position(new_value):
	puppet_global_position = new_value;
	tween.interpolate_property(self, "global_position", global_position, puppet_global_position, 0.1);
	tween.start();

func _enter_tree():
	PlayerData.player_node = self;
func set_times_of_day(data: Dictionary) -> void:
	match data["id"]:
		0:
			for child in get_node("Sprite").get_children():
				child.visible = false;
		1:
			get_node("Sprite/LeftHeadlight").visible = false;
			get_node("Sprite/RightHeadlight").visible = false;
			get_node("Sprite/UnderglowLight").visible = true;
			get_node("Sprite/UnderglowLight").color = "#%s" % PlayerData.personal_data["underglow_light_color"];
		2:
			for child in get_node("Sprite").get_children(): child.visible = true;
			get_node("Sprite/LeftHeadlight").color = "#%s" % PlayerData.personal_data["headlights_color"];
			get_node("Sprite/RightHeadlight").color = "#%s" % PlayerData.personal_data["headlights_color"];
			get_node("Sprite/UnderglowLight").color = "#%s" % PlayerData.personal_data["underglow_light_color"];
func _ready():
	set_times_of_day(GlobalData.settings_data["times_of_day"]);
	yield(get_tree(), "idle_frame");
	if not get_tree().has_network_peer(): return;
	if is_network_master(): GlobalData.master_player = self;

sync func start_vehicle_engine() -> void:
	if vehicle_engine_asp.playing: return;
	match PlayerData.MODE:
		0:
			vehicle_engine_asp.stream = load("res://assets/audio/sfx/vehicle_engine_start.mp3");
			vehicle_engine_asp.play(); return;
		1:
			if not is_network_master(): return;
			vehicle_engine_asp.stream = load("res://assets/audio/sfx/vehicle_engine_start.mp3");
			vehicle_engine_asp.play(); return;
	

func idle_vehicle_engine(velocity_length: float) -> void:
	if GlobalNodes.is_paused == true:
		vehicle_engine_asp.stop();
		friction_asp.stop();
		return;
	if vehicle_engine_asp.playing: pass;
	else:
		match PlayerData.MODE:
			0:
				vehicle_engine_asp.stream = load("res://assets/audio/sfx/vehicle_engine.mp3");
				vehicle_engine_asp.play(); return;
			1:
				if not is_network_master(): return;
				vehicle_engine_asp.stream = load("res://assets/audio/sfx/vehicle_engine.mp3");
				vehicle_engine_asp.play(); return;
	vehicle_engine_asp.volume_db = floor(((velocity_length - (engine_power + 500)) / 100.0) - 3.0);
	
	var slippery_speed: float = (engine_power + 500.0) + 3.0;
	if velocity.length() > slippery_speed and turn != 0:
		if friction_asp.playing == true: friction_asp.stream_paused = false;
		else: friction_asp.play();
	else:
		friction_asp.stream_paused = true;

func input() -> void:
	turn = 0;
	if Input.is_action_pressed("left"): turn -= 1;
	if Input.is_action_pressed("right"): turn += 1;
	direction = (turn * deg2rad(specifications["steering_angle"]));
	
	if Input.is_action_just_pressed("interact"): call("interact");
	if PlayerData.is_auto_acceleration_on:
		if not Input.is_action_pressed("decelerate"): acceleration = (transform.x * (engine_power + 500));
		elif Input.is_action_pressed("decelerate"): acceleration = (transform.x * (-(engine_power + 500)));
	else:
		if Input.is_action_pressed("accelerate"): acceleration = (transform.x * (engine_power + 500));
		elif Input.is_action_pressed("decelerate"): acceleration = (transform.x * (-(engine_power + 500)));

func interact() -> void:
	if control_device == null: return;
	
	if control_device.has_method("transmit") and control_device.state == 1:
		var transmitted_data: String = control_device.call("transmit");
		database.append(transmitted_data);
		get_tree().current_scene.unix_time += 5.0;
		get_tree().current_scene.ui.speedrun_label.get_node("SpeedrunAP").play("zoom_in_out");
		main.emit_signal("RefreshUI")
	elif control_device.has_method("attempt_to_transmit") and control_device.state == 0:
		control_device.call("attempt_to_transmit");
	
	if control_device.has_method("receive") and control_device.state == 1:
		control_device.call("receive");
	elif control_device.has_method("attempt_to_receive") and control_device.state == 0:
		control_device.call("attempt_to_receive");

func _process(delta):
	if GlobalNodes.is_paused == true: return;
	detect();
	idle_vehicle_engine(puppet_velocity.length() if PlayerData.MODE == 1 else velocity.length());
	match PlayerData.MODE:
		0: on_SinglePlayer_process(delta);
		1: on_Multiplayer_process(delta);
		2, 3, 4, 5: on_Challenge_process(delta);
		_: pass;
func on_SinglePlayer_process(delta: float) -> void:
	acceleration = Vector2.ZERO;
	input(); apply_friction(); steer();
	velocity += acceleration * delta;
#	printt(round((velocity.x * (100 / sqrt(12.5))) / 100), velocity.length())
	velocity = move_and_slide(velocity);
func on_Multiplayer_process(delta: float) -> void:
	_sync();
	if not get_tree().has_network_peer(): return;
	if is_network_master() and not GlobalNodes.is_paused:
		on_SinglePlayer_process(delta);
	else:
		rotation = GlobalData.lerp_angle(rotation, puppet_rotation);
		if not tween.is_active():
			velocity = move_and_slide(puppet_velocity * 1);
func on_Challenge_process(delta: float) -> void:
	match PlayerData.MODE:
		2: # The Lava Wall
			var rgb: float = modulate.r;
			var collision: KinematicCollision2D = get_last_slide_collision();
			if collision != null:
				rgb = max(0.0, rgb - 0.01);
			else: rgb = min(1.0, rgb + 0.0025);
			modulate = Color(rgb, rgb, rgb);
			if rgb <= 0.0: _reset();
			on_SinglePlayer_process(delta);
		3: # The Broken Camera
			on_SinglePlayer_process(delta);
		4: # The Reverse Universe
			acceleration = Vector2.ZERO;
			input();
			direction *= -1; # This reverts the left and right turn
			apply_friction(); steer();
			velocity += acceleration * delta;
			velocity = move_and_slide(velocity);
		5: # The Reckless Drive
			if turn != 0: specifications["steering_angle"] += 0.32;
			else: specifications["steering_angle"] = 56;
			on_SinglePlayer_process(delta);
func _reset() -> void:
	velocity = Vector2.ZERO; global_position = Vector2.ZERO;
	modulate = Color(1.0, 1.0, 1.0);
	for child in trail_node.get_children():
		delete_trail(child);

sync func rpc_configure(new_data: Dictionary):
	PlayerData.MODE = new_data["mode"];
	global_position = new_data["global_position"]; puppet_global_position = new_data["global_position"];
	rotation = new_data["rotation"]; puppet_rotation = new_data["rotation"];
	var texture: StreamTexture = load("res://assets/images/sprites/%s.png" % new_data["sprite"]); get_node("Sprite").set_texture(texture);
	get_node("Sprite/LeftHeadlight").color = new_data["headlights_color"];
	get_node("Sprite/RightHeadlight").color = new_data["headlights_color"];
	get_node("Sprite/UnderglowLight").color = new_data["underglow_light_color"];
func _sync() -> void:
	if not get_tree().has_network_peer(): return;
	if is_network_master():
		rset_unreliable("puppet_global_position", global_position); rset_unreliable("puppet_velocity", velocity); rset_unreliable("puppet_rotation", rotation);

func apply_friction() -> void:
	var friction_force: Vector2 = velocity * specifications["friction"];
	var drag_force: Vector2 = velocity * specifications["drag"];
	acceleration += friction_force + drag_force;
func steer(delta: float = get_physics_process_delta_time()) -> void:
	var front_wheel: Vector2 = position + transform.x * (specifications["wheel_base"] / 2.0);
	front_wheel += velocity.rotated(direction) * delta;
	var rear_wheel: Vector2 = position - transform.x * (specifications["wheel_base"] / 2.0);
	rear_wheel += velocity * delta;
	var new_direction = (front_wheel - rear_wheel).normalized();
	attempt_to_drift();
	var dot = new_direction.dot(velocity.normalized());
	if dot > 0: velocity = velocity.linear_interpolate(new_direction * velocity.length(), specifications["grip"]);
	else: velocity = -new_direction * min(velocity.length(), engine_power + 500.0);
	rotation = new_direction.angle();
func attempt_to_drift() -> void:
	var slippery_speed: float = (engine_power + 500) + 3.0;
	if velocity.length() > slippery_speed and turn != 0:
		for child in trail_node.get_children():
			create_trail(child);
	else: for child in trail_node.get_children():
			delete_trail(child);
func create_trail(position_node: Node) -> void:
	if position_node.has_node("%s" % position_node.name): return;
	var trail = trail_tscn.instance();
	trail.start(); trail.name = position_node.name;
	position_node.add_child(trail);
func delete_trail(position_node: Node) -> void:
	if not position_node.has_node("%s" % position_node.name): return;
	var line_node = position_node.get_node("%s" % position_node.name);
	line_node.stop(); line_node.name = "Unused"

func _on_Area2D_body_entered(body: Node) -> void:
	if not body.is_in_group("control_device"): return;
	control_devices.append(body);
func _on_Area2D_body_exited(body: Node):
	if body in control_devices:
		control_devices.erase(body);
func _on_Area2D_area_entered(area: Area2D) -> void:
	if not area.is_in_group("control_device"): return;
	control_devices.append(area.get_parent());
func _on_Area2D_area_exited(area: Area2D) -> void:
	if area.get_parent() in control_devices:
		if not area.name in ["Watchtower"]: return;
		control_devices.erase(area.get_parent());

func detect() -> void:
	if not control_devices.size() > 0:
		control_device = null;
		return;
	var closet_body: Node = null;
	var closet_distance: float = INF;
	for k in control_devices:
		var distance: float = global_position.distance_to(k.global_position);
		if distance < closet_distance:
			closet_body = k;
			closet_distance = distance;
	var space_state = get_world_2d().direct_space_state;
	var result = space_state.intersect_ray(global_position, closet_body.global_position, [self], collision_mask, true, true);
	if not result: return;
	if result.collider.is_in_group("control_device"):
		control_device = closet_body;

func _exit_tree():
	if not get_tree().has_network_peer(): return;
	if is_network_master():
		GlobalData.master_player = null;
