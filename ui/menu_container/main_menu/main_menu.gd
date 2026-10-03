class_name MainMenu
extends Node2D

signal RefreshMainMenu;

onready var curtain_node = $UI/Curtain;
onready var node_2d: Node = $Node2D;
onready var path_tscn: PackedScene = preload("res://ui/menu_container/main_menu/path.tscn");
onready var prologue_ui_path: PackedScene = preload("res://ui/menu_container/main_menu/prologue_ui.tscn");

var main: Node2D;

func _ready():
	var target_background_tscn: PackedScene = load("res://locations/%s/%s.tscn" % [PlayerData.user_data["last_main"], PlayerData.user_data["last_main"]]);
	randomize();
	sync_background(target_background_tscn);
	emit_signal("RefreshMainMenu");
	yield(get_tree().create_timer(2.0), "timeout");
	if GlobalTscn.theme_id != GlobalTscn.main_theme_id:
		GlobalTscn.play_audio(GlobalTscn.main_theme_id);
	if PlayerData.personal_data["name"] == "": add_child(prologue_ui_path.instance());
	curtain_node.queue_free();

func sync_background(background_tscn: PackedScene) -> void:
	var background = background_tscn.instance();
	var path = path_tscn.instance();
	
	for child in background.get_children():
		if not (child.name in ["Environment", "DirectionalLight"]):
			child.queue_free();
	background.add_child(path);
	node_2d.add_child(background);
