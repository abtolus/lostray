extends Transmitter

onready var area: Area2D = $SumArea;

var body_: Node;

func attempt_to_transmit() -> void:
	if body_ == null: return;
	if not GlobalTscn.has_node("MenuLayer/TabletMenu"):
		var identical_digits: Array = get_identical_digits();
		var question: String = get_question(identical_digits);
		var solution: String = get_solution(identical_digits);
		load_tablet_menu(self, [[solution], question]);
func transmit() -> String:
	attempt_to_deactivate();
	return get_random_data();

func get_identical_digits(length: int = 4) -> Array:
	var identical_digits: Array = [];
	var random_digit: int = int(randi() % 3 + 5);
	for _i in length:
		identical_digits.append(random_digit);
	return identical_digits;
func get_question(data: Array) -> String:
	var string: String = String(data[0]);
	for i in range(data.size()):
		if i != 0: string += " + %s" % data[i];
	return string;
func get_solution(data: Array) -> String:
	var solution: int = 0;
	for integer in data:
		solution += integer;
	return str(solution);

func _on_SumArea_body_entered(body: Node):
	if not body.is_in_group("player"): return;
	body_ = body
func _on_SumArea_body_exited(body: Node):
	if body_ == body: body_ = null;
func clear_area() -> void:
	area.queue_free();
