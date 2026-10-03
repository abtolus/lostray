extends Control

onready var main_menu_button: Button = $C/MC/VBC/HBC2/MainMenu;
onready var continue_button: Button = $C/MC/VBC/HBC2/Continue;

onready var title_label: Label = $C/MC/VBC/TitleLabel;
onready var gc: GridContainer = $C/MC/VBC/VBC/C/GC;
onready var total_coins_label: Label = $C/MC/VBC/VBC2/C/HBC/TotalCoinsLabel;
onready var ongoing_coins_label: Label = $C/MC/VBC/VBC2/C/HBC/OngoingCoinsLabel;
onready var result_menu_ap: AnimationPlayer = $ResultMenuAP;

var main: Node; var ongoing_coins_: float = 0.0;

func _ready():
	GlobalNodes.is_paused = true;
	get_tree().paused = true;

func _load(title: Array) -> void:
	title_label.set_text(title[0]);
	title_label.set("custom_colors/font_color", Color(title[1]));
	update_speedrun_timers();
	var total_coins: float = main.total_coins;
	var ongoing_coins: float = main.hacked_quadrants[main.on_quadrant.name.to_lower()]["coins"] if title[0] == "Quadrant Hacked" else main.finished_quadrants[main.on_quadrant.name.to_lower()]["coins"];
	ongoing_coins_ = ongoing_coins;
	total_coins_label.set_text("Total: " + str(total_coins - ongoing_coins));
	ongoing_coins_label.set_text("Ongoing: " + str(ongoing_coins));
	if main.finished_quadrants.keys().size() + main.hacked_quadrants.keys().size() >= 4:
		continue_button.visible = false;
		return;
func update_speedrun_timers() -> void:
	for child in gc.get_children():
		if ((child.text in ["Not finished"]) and (not child.text in ["Has hacked"])) and (child.name.to_lower() in main.finished_quadrants):
			child.set_text(GlobalData.get_time(main.finished_quadrants[child.name.to_lower()]["unix_time"]));
			child.set("custom_colors/font_color", Color("d6d6ff"));
		elif (child.text in ["Not finished"]) and (child.name.to_lower() in main.hacked_quadrants):
			child.set_text("Has hacked");
			child.set("custom_colors/font_color", Color("ff2020"));

#func _load(title: Array) -> void:
	
#	var finished_array: Array = main.finished_quadrants.keys(); var hacked_array: Array = main.hacked_quadrants.keys();
#	var array: Array = [];
#	array.append_array(finished_array); array.append_array(hacked_array);
#	for i in array:
#		if i in finished_array:
#			var unix_time = main.finished_quadrants[i]["unix_time"];
#			if unix_time != null:gc.get_child(finished_array.find(i)).set_text(GlobalData.get_time(unix_time));
#			elif unix_time == null or unix_time == 0.0: gc.get_child(finished_array.find(i)).set_text("Not finished");
#		elif i in hacked_array:
#			var label: Label = gc.get_child(hacked_array.find(i));
#			label.set_text("Has hacked"); label.set("custom_colors/font_color", Color("ff2020"));
#	if array.size() < 1: return;
#	if main.finished_quadrants.has(array[0]):
#		coins_label.text += str(main.finished_quadrants[array[0]]["coins"]);
#	elif main.hacked_quadrants.has(array[0]):
#		coins_label.text += str(ceil(main.hacked_quadrants[array[0]]["coins"] / 2.0));
#	for i in range(array.size()):
#		if not i == 0:
#			if main.finished_quadrants.has(array[0]): coins_label.text += " + " + str(main.finished_quadrants[array[i]]["coins"]);
#			elif main.hacked_quadrants.has(array[0]): coins_label.text += " + " + str(ceil(main.hacked_quadrants[array[i]]["coins"] / 2.0));

func start_addition() -> void:
	main_menu_button.disabled = true;
	continue_button.disabled = true;
	ongoing_coins_label.set_text(str(ongoing_coins_));
	result_menu_ap.play("addition");
	yield(get_tree().create_timer(1.9), "timeout");
	total_coins_label.set_text("Total: " + str(main.total_coins));
	yield(result_menu_ap, "animation_finished");

func _on_MainMenu_button_up():
	PlayerData.player_node.vehicle_engine_asp.stop();
	PlayerData.player_node.friction_asp.stop();
	get_tree().paused = false;
	yield(start_addition(), "completed");
	PlayerData.personal_data["coins"] += main.total_coins; # Add the collected coins
	GlobalTscn.change_scene_tree(load("res://ui/menu_container/main_menu/main_menu.tscn"), GlobalTscn.main_theme_id);
	GlobalTscn.clear_menu_layer(); GlobalNodes.get_node("Player").queue_free();
	queue_free();
func _on_Continue_button_up():
	PlayerData.player_node.vehicle_engine_asp.stop();
	PlayerData.player_node.friction_asp.stop();
	get_tree().paused = false;
	yield(start_addition(), "completed");
	main.restart(); # Prepare for the next quadrant
	queue_free();
