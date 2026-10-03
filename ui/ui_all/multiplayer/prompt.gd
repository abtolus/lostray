extends Control

var mode: int = -1;

func set_text(string: String = "") -> void:
	var string_label = $C/MC/VBC/ColorRect/String;
	string_label.text = string;

func _on_Okay_button_up():
	match mode:
		0: queue_free();
		1:
			GlobalTscn.change_scene_tree(load("res://ui/menu_container/main_menu/main_menu.tscn"), GlobalTscn.main_theme_id);
			GlobalTscn.clear_menu_layer();
		_: pass;
