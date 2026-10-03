extends Camera2D

var previous_global_position: Vector2; var previous_rotation: float;
var camera_rotation_speed: float = GlobalData.settings_data["camera_rotation_speed"]["value"];

func _process(delta):
	if GlobalNodes.has_node("Player"):
		rotation = GlobalData.lerp_angle(rotation, GlobalNodes.get_node("Player").rotation + deg2rad(90), camera_rotation_speed);
		global_position = lerp(global_position, GlobalNodes.get_node("Player").global_position, delta * 10);
		previous_global_position = global_position; previous_rotation = rotation;
	else:
		global_position = previous_global_position; rotation = previous_rotation;
