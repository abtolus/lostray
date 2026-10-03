extends Line2D

var trail_lifetime: float = 6.0;
var is_started: bool = false;
var start_time: int = 0
var initial_time: float = 0.0 setget get_initial_time;

func get_initial_time(_value) -> float:
	return (Time.get_ticks_msec() - start_time) / 1000.0

func _ready():
	set_as_toplevel(true);

func _physics_process(_delta):
	if is_started:
		var point = get_parent().global_position;
		add_point(point);
	if points.size() <= 0:
		if initial_time > trail_lifetime:
			queue_free();

func start() -> void:
	is_started = true;
	initial_time = Time.get_ticks_msec()

func stop() -> void:
	is_started = false

func _on_FadeOut_timeout():
	remove_point(0)
#	for _i in range(2):
#		if points.size() == 0:
#			return
#		else:
#			remove_point(0)
