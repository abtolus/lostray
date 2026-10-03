extends Node2D

onready var path_follow_2d = $Path2D/PathFollow2D

func _enter_tree():
	if PlayerData.player_node != null and is_instance_valid(PlayerData.player_node):
		if PlayerData.player_node.name != "Player": return;
	PlayerData.player_node = $Path2D/PathFollow2D;

func _physics_process(delta):
	path_follow_2d.unit_offset += delta * 0.0064;
