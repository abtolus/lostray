extends Control

onready var single_player_button: Button = $Control/VBC/SinglePlayer;
onready var multiplayer_button: Button = $Control/VBC/Multiplayer;
onready var challenge_button: Button = $Control/VBC/Challenge;
onready var back_button: Button = $CR2/Back;

func _disable(boolean: bool) -> void:
	single_player_button.disabled = boolean; multiplayer_button.disabled = boolean;
	challenge_button.disabled = boolean; back_button.disabled = boolean;

func _on_Back_button_up():
	queue_free();
func _on_Multiplayer_button_up():
	_disable(true);
	yield(GlobalTscn.request(), "completed");
	_disable(false);
	if NetworkData.network_status != 1:
		var prompt = load("res://ui/ui_all/multiplayer/prompt.tscn").instance();
		var string: String = "You are not connected to the internet";
		prompt.mode = 0; prompt.set_text(string);
		GlobalTscn.load_menu(prompt);
		return;
	GlobalTscn.load_menu(load("res://ui/menu_container/multiplayer_menu/multiplayer_menu.tscn").instance());
func _on_SinglePlayer_button_up():
	GlobalTscn.load_menu(load("res://ui/menu_container/single_player_menu/single_player_menu.tscn").instance());
func _on_Challenge_button_up():
	GlobalTscn.load_menu(load("res://ui/menu_container/challenge_menu/challenge_menu.tscn").instance());
