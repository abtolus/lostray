extends Transmitter

onready var parking_lot: Area2D = $ParkingLot;

var parked_body: Node;

func _ready(): attempt_to_deactivate();

func transmit() -> String:
	parking_lot.queue_free();
	attempt_to_deactivate();
	return get_random_data();

func _physics_process(_delta):
	if parked_body == null: return;
	var rotation_difference: float = abs(abs(parked_body.global_rotation_degrees) - abs(parking_lot.global_rotation_degrees));
	var opposite_rotation_difference: float = abs(abs(parked_body.global_rotation_degrees) - get_opposite_rotation(abs(parking_lot.global_rotation_degrees)))
	var position_difference: float = parked_body.global_position.distance_to(parking_lot.global_position);
	
	if (rotation_difference <= 8.0 or opposite_rotation_difference <= 8.0) and position_difference <= 24.0:
		parking_lot.get_node("Panel").set("custom_styles/panel", get_parking_lot_tres("00ff00"));
		attempt_to_activate();
	else:
		parking_lot.get_node("Panel").set("custom_styles/panel", get_parking_lot_tres("ffa500"));
		attempt_to_deactivate();

func get_opposite_rotation(global_rotation_degrees_: float) -> float:
	if abs(180.0 - global_rotation_degrees_) <= 6.0: return 0.0;
	elif abs(0.0 - global_rotation_degrees_) <= 6.0: return 180.0;
	else: return global_rotation_degrees_;
func _on_ParkingLot_body_entered(body: Node):
	if not body.is_in_group("player"): return;
	parked_body = body;
func _on_ParkingLot_body_exited(body: Node):
	if parked_body == body: parked_body = null;
func get_parking_lot_tres(color: String) -> StyleBoxFlat:
	var style_box_flat: StyleBoxFlat = StyleBoxFlat.new();
	style_box_flat.bg_color = Color("00000000");
	style_box_flat.border_width_bottom = 8; style_box_flat.border_width_left = 8;
	style_box_flat.border_width_right = 8; style_box_flat.border_width_top = 8;
	style_box_flat.border_color = Color(color);
	return style_box_flat;
