extends Control

func _on_RainforestTB_button_up():
	change_scene_tree("rainforest");
func _on_SavannahTB_button_up():
	change_scene_tree("savannah");
func _on_DesertTB_button_up():
	change_scene_tree("desert");
func _on_TundraTB_button_up():
	change_scene_tree("tundra");

func change_scene_tree(string: String) -> void:
	PlayerData.MODE = 0; GlobalTscn.clear_menu_layer();
	GlobalTscn.change_scene_tree(load("res://locations/%s/%s.tscn" % [string, string]), GlobalTscn.last_bastion_id);

func _on_Back_button_up():
	queue_free();
