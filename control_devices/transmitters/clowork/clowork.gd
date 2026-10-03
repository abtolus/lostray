extends Transmitter

onready var clockwork_surface: Area2D = $ClockworkSurface;
onready var player_hand: Node2D = $ClockworkSurface/PlayerHand;
onready var clowork_hand: Node2D = $ClockworkSurface/CloworkHand;

var body_: Node; var has_started: bool = false;
onready var direction: int = 1; onready var player_direction: int = 1;
onready var chances: Array = [90, 45, 15];

func _ready():
	attempt_to_deactivate();

func place_player(player: Player) -> void:
	GlobalNodes.is_paused = true;
	var tween: SceneTreeTween = create_tween();
	tween.tween_property(player, "global_position", clockwork_surface.global_position, 1.0);
	player.global_rotation = player_hand.global_rotation;
	player.rotation = player_hand.global_rotation
	player.scale = Vector2(0.5, 0.5);
func attempt_to_transmit() -> void:
	if body_ == null: return;
	place_player(body_);
	has_started = true;
	
func transmit() -> String:
	clockwork_surface.queue_free();
	attempt_to_deactivate();
	return get_random_data();

func _physics_process(_delta):
	if not has_started or body_ == null: return;
	if Input.is_action_just_pressed("left"): player_direction = 1;
	elif Input.is_action_just_pressed("right"): player_direction = -1;
	var rotation_difference: float = abs(player_hand.global_rotation_degrees - clowork_hand.global_rotation_degrees);
	if rotation_difference <= 2.0:
		player_hand.queue_free(); clowork_hand.queue_free();
		set_physics_process(false); attempt_to_activate();
		body_.scale = Vector2(1, 1);
		GlobalNodes.is_paused = false;
		return;
	player_hand.global_rotation_degrees += player_direction;
	body_.global_rotation_degrees = player_hand.global_rotation_degrees - 90;
	clowork_hand.global_rotation_degrees += direction;
	if chances.size() <= 0: return;
	if rotation_difference < chances[0]:
		direction *= -1; chances.pop_front();

func _on_CloworkSurface_body_entered(body: Node):
	if not body.is_in_group("player"): return;
	body_ = body;
func _on_CloworkSurface_body_exited(body: Node):
	if body_ == body: body_ = null;
