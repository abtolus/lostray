extends Camera2D

var master_player: KinematicBody2D = null;
var previous_global_position: Vector2 = Vector2.ZERO;
var previous_rotation: float = 0.0;

func _process(delta):
	if (GlobalData.master_player and is_instance_valid(GlobalData.master_player)) and not GlobalData.master_player.name in get_parent().qualified_players:
		rotation = GlobalData.lerp_angle(rotation, GlobalData.master_player.rotation + deg2rad(90));
		global_position = lerp(global_position, GlobalData.master_player.global_position, delta * 10);
		previous_rotation = rotation; previous_global_position = global_position;
	else:
		# If the player is leaving the server
		if GlobalNodes.get_child_count() == 0:
			global_position = previous_global_position; rotation = previous_rotation;
			return;
		# If not
		if master_player == null:
			var random_index: int = randi() % (GlobalNodes.get_child_count() - 1);
			master_player = GlobalNodes.get_child(random_index);
			spectate(random_index);
		else:
			rotation = GlobalData.lerp_angle(rotation, master_player.rotation + deg2rad(90));
			global_position = lerp(global_position, master_player.global_position, delta * 10);

func spectate(random_index: int) -> void:
	var master_index: int = GlobalNodes.get_index_by_peer_id(GlobalData.master_player.name);
	var spectator = GlobalData.instantiate_node(load("res://ui/ui_all/multiplayer/spectator.tscn"), get_node("../MultiplayerUI"));
	spectator.camera = self; spectator.index = random_index; spectator.master_index = master_index;
