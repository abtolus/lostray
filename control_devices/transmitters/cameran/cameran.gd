extends Transmitter

onready var camera_viewport: Area2D = $CameraViewport;

var detected_body: Node;
var rotation_degrees_array: Array = [0.0, 90.0, 180.0, 270.0];

func _ready():
	set_default_camera_viewport_tres();
	var random_index: int = randi() % rotation_degrees_array.size();
	camera_viewport.rotation_degrees = rotation_degrees_array[random_index];
	rotation_degrees_array.erase(rotation_degrees_array[random_index]);
	attempt_to_deactivate();

func transmit() -> String:
	camera_viewport.queue_free();
	attempt_to_deactivate();
	return get_random_data();

func _physics_process(_delta):
	if detected_body == null: return;
	var rotation_difference: float = abs(detected_body.global_rotation_degrees - camera_viewport.global_rotation_degrees);
	var position_difference: float = detected_body.global_position.distance_to(camera_viewport.global_position);
	
	if rotation_difference <= 16.0 and position_difference <= 64.0:
		camera_viewport.get_node("Panel").set("custom_styles/panel", get_camera_viewport_tres("ffa500"));
		camera_viewport.get_node("Panel/TextureRect").self_modulate = Color("90ffa500");
		set_physics_process(false);
		yield(get_tree().create_timer(1), "timeout");
		if rotation_degrees_array.size() <= 2:
			set_physics_process(false);
			attempt_to_activate();
			camera_viewport.get_node("Panel/TextureRect").hide();
			camera_viewport.get_node("Panel").set("custom_styles/panel", get_camera_viewport_tres("00ff00"));
			return;
		var random_index: int = randi() % rotation_degrees_array.size();
		camera_viewport.rotation_degrees = rotation_degrees_array[random_index];
		rotation_degrees_array.erase(rotation_degrees_array[random_index]);
		set_physics_process(true);
		set_default_camera_viewport_tres();
	else:
		set_default_camera_viewport_tres();

func set_default_camera_viewport_tres() -> void:
	camera_viewport.get_node("Panel/TextureRect").self_modulate = Color("90ffffff");
	camera_viewport.get_node("Panel").set("custom_styles/panel", get_camera_viewport_tres("ffffff"));
func get_camera_viewport_tres(color: String) -> StyleBoxFlat:
	var style_box_flat: StyleBoxFlat = StyleBoxFlat.new();
	style_box_flat.bg_color = Color("00000000");
	style_box_flat.border_width_bottom = 8; style_box_flat.border_width_left = 8;
	style_box_flat.border_width_right = 8; style_box_flat.border_width_top = 8;
	style_box_flat.border_color = Color(color);
	return style_box_flat;

func _on_CameraViewport_body_entered(body: Node):
	if not body.is_in_group("player"): return;
	detected_body = body;

func _on_CameraViewport_body_exited(body: Node):
	if detected_body == body: detected_body = null;
