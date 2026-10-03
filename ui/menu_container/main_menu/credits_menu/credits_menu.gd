extends Control

onready var sc = $C/SC;
onready var back_button: Button = $CR2/Back;

var is_playing: bool = false;

func _ready():
	back_button.visible = false;
	is_playing = true;

func _physics_process(delta: float) -> void:
	if not is_playing: return;
	scroll_vertical(delta);
func scroll_vertical(delta: float) -> void:
	sc.scroll_vertical += 120 * delta;
	sc.scroll_vertical = min(2725.0, sc.scroll_vertical);
	if sc.scroll_vertical >= 512 and back_button.visible == false:
		back_button.visible = true;
	if sc.scroll_vertical >= 2725.0:
		is_playing = false;
		back_button.disabled = true;
		yield(get_tree().create_timer(1), "timeout");
		_on_Back_button_up();

func _on_Back_button_up():
	queue_free();
