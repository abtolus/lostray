extends Control

onready var label: Node = $MC/HBC/Label;
var camera: Node;
var index: int;
var master_index: int;

func _ready():
	update_spectated_player(index);

func update_spectated_player(final_index: int):
	var peer_id: String = GlobalNodes.get_child(final_index).name;
	var peer_username: String = NetworkData.network_data[peer_id]["name"];
	label.set_text(peer_username);
	index = final_index;

func _on_TBL_button_up():
	var local_index = index;
	if local_index == 0: local_index = GlobalNodes.get_children().size() - 1; else: local_index -= 1;
	if local_index == master_index: if local_index == 0: local_index = GlobalNodes.get_children().size() - 1; else: local_index -= 1;
	camera.master_player = GlobalNodes.get_child(local_index);
	update_spectated_player(local_index);
func _on_TBR_button_up():
	var local_index = index;
	if local_index == GlobalNodes.get_child_count() - 1: local_index = 0; else: local_index += 1;
	if local_index == master_index: if local_index == GlobalNodes.get_child_count() - 1: local_index = 0; else: local_index += 1;
	camera.master_player = GlobalNodes.get_child(local_index);
	update_spectated_player(local_index);
