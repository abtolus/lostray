extends Control

onready var challenge_name_label: Label = $C/MC/VBC/ChallengeNameLabel;
onready var challenge_description_label: Label = $C/MC/VBC/Control/VBC/ChallengeDescriptionLabel;

var MODE: int = -1;

func get_daily_challenge(previous_id: int):
	var new_id: int = GlobalData.challenge_data.keys()[randi() % GlobalData.challenge_data.keys().size()];
	while previous_id == new_id:
		new_id = GlobalData.challenge_data.keys()[randi() % GlobalData.challenge_data.keys().size()];
	var daily_challenge_data: Dictionary = GlobalData.challenge_data[new_id];
	daily_challenge_data["last_unix_time"] = Time.get_unix_time_from_system();
	daily_challenge_data["id"] = new_id;
	return daily_challenge_data;
func _ready() -> void:
	var daily_challenge_data: Dictionary;
	if PlayerData.user_data["last_challenge"] == null:
		daily_challenge_data = get_daily_challenge(100);
		PlayerData.user_data["last_challenge"] = daily_challenge_data;
	else: 
		daily_challenge_data = PlayerData.user_data["last_challenge"];
	var last_unix_time: float = daily_challenge_data["last_unix_time"];
	var new_unix_time: float = Time.get_unix_time_from_system();
	# After 2 hours
	if GlobalData.has_passed(new_unix_time - last_unix_time):
		daily_challenge_data = get_daily_challenge(PlayerData.user_data["last_challenge"]["id"]);
		PlayerData.user_data["last_challenge"] = daily_challenge_data;
		PlayerData.user_data["last_challenge"]["last_unix_time"] = new_unix_time;
	var challenge_name: String = daily_challenge_data["name"];
	var challenge_description: String = daily_challenge_data["description"];
	MODE = daily_challenge_data["mode"];
	
	challenge_name_label.set_text(challenge_name);
	challenge_description_label.set_text(challenge_description);

func _on_Accept_button_up():
#	var mains: Array = ["rainforest", "desert", "savannah", "tundra"]
	var mains: Array = ["savannah"]
	var random_main: String = mains[randi() % mains.size()];
	PlayerData.MODE = MODE;
	GlobalTscn.clear_menu_layer();
	GlobalTscn.change_scene_tree(load("res://locations/%s/%s.tscn" % [random_main, random_main]), GlobalTscn.extra_ordinance_id);

func _on_Back_button_up(): queue_free();
