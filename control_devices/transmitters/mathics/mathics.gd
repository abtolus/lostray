extends Transmitter

onready var area: Area2D = $MathematicalStage;

var body_: Node;

func attempt_to_transmit() -> void:
	if body_ == null: return;
	if not GlobalTscn.has_node("MenuLayer/TabletMenu"):
		var shuffled_digits: Array = get_shuffled_digits();
		var question: String = get_question(shuffled_digits);
		var solution: String = get_solution(shuffled_digits);
		load_tablet_menu(self, [[solution], question]);
func transmit():
	attempt_to_deactivate();
	return get_random_data();

func get_shuffled_digits(length: int = 4) -> Array:
	var shuffled_digits: Array = [];
	for _i in length:
		randomize();
		shuffled_digits.append(randi() % 4 + 4);
	return shuffled_digits;
func get_question(data: Array):
	return "(%d + %d) + (%d + %d)" % [data[0], data[1], data[2], data[3]];
func get_solution(data: Array) -> String:
	var solution: int = 0;
	for integer in data:
		solution += integer;
	return str(solution);

func _on_MathematicalStage_body_entered(body: Node):
	if not body.is_in_group("player"): return;
	body_ = body;
func _on_MathematicalStage_body_exited(body: Node):
	if body_ == body: body_ = null;
func clear_area() -> void:
	area.queue_free();
