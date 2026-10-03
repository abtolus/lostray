extends Control

onready var display_label: Label = $Control/MC/VBC/DisplayLabel;
onready var line_edit = $Control/MC/VBC/LineEdit;

var node: Node;
var solutions: Array;

func _load(display_text: String):
	display_label.set_text(display_text);

func _on_Back_button_up():
	node.body_ = null;
	GlobalData.change_visibility([node.cui], [true]); GlobalNodes.is_paused = false;
	if node.name == "Watchtower":
		node.main.is_playing = true; # Make the main do processing
	queue_free();
func _on_Confirm_button_up():
	if not (line_edit.text in solutions):
		line_edit.clear(); line_edit.placeholder_text = "Incorrect";
		return;
	node.attempt_to_activate(); node.body_ = null;
	if node.has_method("clear_area"): node.clear_area();
	GlobalData.change_visibility([node.cui], [true]);
	if node.name == "Watchtower":
		PlayerData.player_node.global_position = Vector2.ZERO;
		PlayerData.player_node.interact();
	else: GlobalNodes.is_paused = false;
	queue_free();
