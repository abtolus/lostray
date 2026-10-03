class_name ElectricDoor
extends StaticBody2D

var body_: Node; onready var main: Node = get_node("../../..");
onready var quadrant: Node = get_node("..");
var state: int = 0; var unlocked: bool = false;

func attempt_to_transmit() -> void:
	if body_ == null or unlocked == false: return;
	for child in quadrant.get_children():
		if child.is_in_group("electric_door"):
			child.visible = false;
	main.start(quadrant);

func _ready():
	_on_ElectricDoor_visibility_changed();

func _on_ElectricDoor_visibility_changed():
	if visible == true:
		set_collision_layer_bit(2, true);
		set_collision_layer_bit(1, true);
		set_collision_mask_bit(0, true);
	else:
		set_collision_layer_bit(2, false);
		set_collision_layer_bit(1, false);
		set_collision_mask_bit(0, false);

func _on_Sensor_body_entered(body: Node):
	if not body.is_in_group("player"): return;
	body_ = body;
func _on_Sensor_body_exited(body: Node):
	if body_ == body: body_ = null;
