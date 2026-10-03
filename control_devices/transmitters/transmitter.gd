class_name Transmitter
extends ControlDevice

onready var cui: CanvasLayer = get_node("../../../UI/CUI");

func attempt_to_activate() -> void: activate("res://assets/images/sprites/transmitter_active.png");
func attempt_to_deactivate() -> void: deactivate("res://assets/images/sprites/transmitter_inactive.png");

func _ready():
	attempt_to_deactivate();

func get_random_digits(number: int = 5, offset: int = 0, max_number: int = 6) -> String:
	randomize();
	var random_digits: String = "";
	for _i in range(number):
		random_digits += str(randi() % max_number + offset);
	return random_digits;

func get_random_data() -> String:
	randomize();
	var operator: String = "+" if randi() % 2 == 0 else "-";
	var numeral: String = str(randi() % 8 + 1);
	return "%s%s" % [operator, numeral] if randi() % 2 == 0 else "%s%s" % [numeral, operator];
