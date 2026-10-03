extends Control

onready var main: Node2D = get_node("../..");

func _ready():
	GlobalTscn.fade_audio(-8, 1.0);
	get_tree().paused = true;

func _on_Resume_button_up():
	GlobalData.change_visibility([get_parent().cui, get_parent().tui], [true, true]); # Also show the speedrun timer
	if main.unix_time <= main.get_unix_time_by_difficulty(GlobalData.settings_data["difficulty"]["value"]) - 0.1: main.is_playing = true;
	GlobalNodes.is_paused = false; get_tree().paused = false;# Unleash the game
	GlobalTscn.fade_audio(0, 1.0);
	queue_free();
func _on_MainMenu_button_up():
	PlayerData.player_node.vehicle_engine_asp.stop();
	PlayerData.player_node.friction_asp.stop();
	get_tree().paused = false;
	yield(GlobalTscn.fade_audio(0, 0.1), "completed"); # Wait until the audio is completed faded out
	PlayerData.personal_data["coins"] += main.total_coins; # Add the collected coins
	GlobalTscn.change_scene_tree(load("res://ui/menu_container/main_menu/main_menu.tscn"), GlobalTscn.main_theme_id);
	GlobalTscn.clear_menu_layer(); GlobalNodes.get_node("Player").queue_free();
	queue_free();
func _on_Tutorial_button_up():
	GlobalTscn.clear_menu_layer();
	GlobalTscn.load_menu(load("res://ui/menu_container/single_player_menu/tutorial_menu/tutorial_menu.tscn").instance());
