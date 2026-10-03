extends Transmitter

onready var area = $VaultBreaker;

var body_: Node;

func attempt_to_transmit() -> void:
	if body_ == null: return;
	if not GlobalTscn.has_node("MenuLayer/TabletMenu"):
		var decreasing_digits: Array = get_decreasing_digits();
		var question: String = get_question(decreasing_digits);
		var solution: String = get_solution(decreasing_digits);
		load_tablet_menu(self, [[solution], question]);
func transmit():
	attempt_to_deactivate();
	return get_random_data();

func get_decreasing_digits(length: int = 4) -> Array:
	var decreasing_digits: Array = [];
	var initial_digit: int = int(randi() % 10 + 25);
	decreasing_digits.append(initial_digit);
	for i in range(length):
		if i != 1: decreasing_digits.append(int(randi() % 2 + 4));
	return decreasing_digits;
func get_question(data: Array) -> String:
	var string: String = String(data[0]);
	for i in range(data.size()):
		if i != 0: string += " - %s" % data[i];
	return string;
func get_solution(data: Array) -> String:
	var solution: int = data[0];
	for integer in data:
		if solution != integer: solution -= integer;
	return str(solution);

func _on_VaultBreaker_body_entered(body: Node):
	if not body.is_in_group("player"): return;
	body_ = body;
func _on_VaultBreaker_body_exited(body: Node):
	if body_ == body: body_ = null;
func clear_area() -> void:
	area.queue_free();
