class_name ControlDevice
extends StaticBody2D

onready var sprite: Sprite = $Sprite;

var state: int = -1;

# Prerequisites [soulution, question]
func load_tablet_menu(parent: Node, prerequisites: Array) -> void:
	var tablet_menu = GlobalData.instantiate_node(load("res://ui/menu_container/single_player_menu/tablet_menu/tablet_menu.tscn"), GlobalTscn.get_node("MenuLayer"));
	tablet_menu.node = parent; tablet_menu.solutions = prerequisites[0];
	tablet_menu._load(prerequisites[1]);
	
	GlobalData.change_visibility([parent.cui], [false]); GlobalNodes.is_paused = true; # Make the player stop moving
	var tween: SceneTreeTween = create_tween();
	tween.tween_property(parent.body_, "global_position", parent.area.global_position, 0.5);

func activate(active_texture: String) -> void:
	state = 1; sprite.set_texture(load(active_texture));
func deactivate(inactive_texture: String) -> void:
	state = 0; sprite.set_texture(load(inactive_texture));
