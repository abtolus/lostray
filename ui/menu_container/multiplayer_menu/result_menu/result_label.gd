extends Control

onready var label = $Label;

var username: String;

func ready() -> void:
	label.set_text(username);
