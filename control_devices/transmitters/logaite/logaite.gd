extends Transmitter

onready var area: Area2D = $LogicGate;

var body_: Node;

func attempt_to_transmit() -> void:
	if body_ == null: return;
	if not GlobalTscn.has_node("MenuLayer/TabletMenu"):
		var increasing_digits: Array = get_increasing_digits();
		var question: String = get_question(increasing_digits);
		var solution: String = get_solution(increasing_digits);
		load_tablet_menu(self, [[solution], question]);
func transmit() -> String:
	attempt_to_deactivate();
	return get_random_data();

func get_increasing_digits(length: int = 4) -> Array:
	var increasing_digits: Array = [];
	var initial_digit: int = int(randi() % 4 + 2);
	var increment: int = int(randi() % 2 + 2)
	for _i in range(length):
		increasing_digits.append(initial_digit);
		initial_digit += increment;
	return increasing_digits;
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

func _on_LogicGate_body_entered(body: Node):
	if not body.is_in_group("player"): return;
	body_ = body;
func _on_LogicGate_body_exited(body: Node):
	if body_ == body: body = null;
func clear_area() -> void:
	area.queue_free();
