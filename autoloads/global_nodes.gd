extends Node2D

onready var is_paused: bool = true;

func get_index_by_peer_id(peer_id: String):
	for index in range(GlobalNodes.get_child_count()):
		if GlobalNodes.get_child(index).name == peer_id:
			return index;
