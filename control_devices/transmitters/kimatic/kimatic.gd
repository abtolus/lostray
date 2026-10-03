extends Transmitter

onready var path_follow: PathFollow2D = $Path2D/PathFollow2D;
onready var moving_platform: Area2D = $Path2D/PathFollow2D/MovingPlatform;

var body_: Node = null;
var direction: int = 1;
var random_start: float; var random_end: float;
var captured_colors: Array = []; var available_colors: Array = ["ff0000", "00ff00", "0000ff"];
var color: String = "c0c0c0";
var has_started: bool = false;

func _ready():
	path_follow.offset = path_follow.get_parent().curve.get_baked_length() / 2.0;
	random_start = get_random_start(); random_end = get_random_end();
	attempt_to_deactivate();

func attempt_to_transmit() -> void:
	if has_started == false and body_ != null:
		has_started = true; direction = [1, -1][randi() % 2]; return;
	if color == "c0c0c0" or color in captured_colors: return;
	captured_colors.append(color); available_colors.erase(color);
func transmit() -> String:
	var style_box_flat = moving_platform.get_node("Panel").get_stylebox("panel");
	change_color(style_box_flat, "c0c0c0");
	moving_platform.queue_free();
	attempt_to_deactivate();
	return get_random_data();

func _physics_process(delta):
	if has_started == false: return;
	if captured_colors.size() == 3:
		var style_box = moving_platform.get_node("Panel").get_stylebox("panel");
		style_box.border_color = Color("ffffffff");
		attempt_to_activate(); set_physics_process(false); return;
	var alpha: float = moving_platform.modulate.a;
	if alpha <= 0.32: change_alpha(moving_platform, 0.64);
	elif alpha >= 0.64: change_alpha(moving_platform, 0.32);
	path_follow.offset += 80 * direction * delta;
	if path_follow.offset >= random_end:
		direction = -1;
		random_start = get_random_start();
	elif path_follow.offset <= random_start:
		direction = 1;
		random_end = get_random_end();
	if (available_colors.size() > 0) and get_node("../../..").is_playing == true:
		attempt_to_change_color();

func attempt_to_change_color() -> void:
	var style_box_flat = moving_platform.get_node("Panel").get_stylebox("panel");
	if style_box_flat.border_color.to_html() == "ffc0c0c0":
		color = available_colors[randi() % available_colors.size()];
		change_color(style_box_flat, color)
	elif style_box_flat.border_color.to_html() == "ff" + color:
		change_color(style_box_flat, "c0c0c0");
	yield(get_tree().create_timer(1), "timeout");

func change_color(object: Object, to: String) -> void:
	var tween: SceneTreeTween = create_tween();
	tween.tween_property(object, "border_color", Color("ff" + to), 1.6);
func change_alpha(node: Node, to: float) -> void:
	var tween: SceneTreeTween = create_tween();
	tween.tween_property(node, "modulate:a", to, 1.6);
func get_random_start() -> float: return rand_range(16.0, 128.0);
func get_random_end() -> float:
	return rand_range(path_follow.get_parent().curve.get_baked_length() - 16.0, path_follow.get_parent().curve.get_baked_length() - 128.0)
func get_moving_platform_tres(color_: String) -> StyleBoxFlat:
	var style_box_flat: StyleBoxFlat = StyleBoxFlat.new();
	style_box_flat.bg_color = Color("00000000");
	style_box_flat.border_width_bottom = 8; style_box_flat.border_width_left = 8;
	style_box_flat.border_width_right = 8; style_box_flat.border_width_top = 8;
	style_box_flat.border_color = Color(color_);
	return style_box_flat;

func _on_MovingPlatform_body_entered(body: Node):
	if not body.is_in_group("player"): return;
	body_ = body;

func _on_MovingPlatform_body_exited(body: Node):
	if body_ == body: body_ = null;
