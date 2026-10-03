extends Node

const URL: String = "https://www.google.com"; var has_requested: bool = false;

onready var transition_layer: Node = $TransitionLayer;
onready var menu_layer = $MenuLayer;
onready var save_data_timer = $Timers/SaveData;
onready var network_agent: HTTPRequest = $NetworkAgent;
onready var theme_asp: AudioStreamPlayer = $Audio/ThemeASP;
onready var tweener: Tween = $Tweener;

onready var fps_label: Label = $TopLayer/C/CR/FPSLabel;

const main_theme_id: String = "lastyon_main_theme";
const last_bastion_id: String = "lastyon_endless_eureka";
const extra_ordinance_id: String = "lastyon_dimensionless_driveway";

var theme_id: String;

func _ready():
	network_agent.connect("request_completed", self, "_request_completed");
	fps_label.get_parent().visible = GlobalData.settings_data["show_fps"];
func _physics_process(_delta) -> void:
	if fps_label.get_parent().visible != true: return;
	fps_label.set_text("%s FPS" % str(Engine.get_frames_per_second()));

func request() -> void:
	network_agent.request(URL);
	yield(network_agent, "request_completed");
	yield(get_tree().create_timer(0.1), "timeout");
	print_debug("Request was completed...")
func _request_completed(result: int, _response_code: int, _headers: PoolStringArray, _body: PoolByteArray) -> void:
	match result:
		0: NetworkData.network_status = 1;
		3, 5, 6, 8, 12: NetworkData.network_status = 0;
		_: NetworkData.network_status = 0;

func change_scene_tree(to: PackedScene, id: String) -> void:
	stop_audio(id);
	transition_layer.get_node("TransitionAP").play("fade_in");
	yield(transition_layer.get_node("TransitionAP"), "animation_finished");
	get_tree().change_scene_to(to);
	yield(get_tree().create_timer(2), "timeout"); transition_layer.get_node("TransitionAP").play("fade_out");
	yield(transition_layer.get_node("TransitionAP"), "animation_finished");
	play_audio(id);
func play_audio(id: String, object: Object = theme_asp) -> void:
	var stream = load("res://assets/audio/music/%s.mp3" % id);
	if object.stream == null:
		object.stream = stream; object.play();
	else: object.stream = stream; object.playing = true;
func stop_audio(id: String, object: Object = theme_asp) -> void:
	theme_id = id;
	if not object.is_playing(): return;
	object.playing = false;

func load_menu(menu: Node) -> void: menu_layer.call_deferred("add_child", menu);
func clear_menu_layer() -> void:
	for menu in menu_layer.get_children(): menu.queue_free();
func is_audio(stream: Object, object: Object = theme_asp) -> bool:
	return true if object.stream == stream else false;
func fade_audio(to: float, duration: float, object: Object = theme_asp) -> void:
	tweener.stop_all();
	tweener.interpolate_property(object, "volume_db", theme_asp.volume_db, to, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
	tweener.start();
	yield(get_tree().create_timer(duration), "timeout");

func _on_SaveData_timeout():
	GlobalData.save_data();
	PlayerData.save_data();
func _on_NetworkData_timeout():
	NetworkData.stable = false;
