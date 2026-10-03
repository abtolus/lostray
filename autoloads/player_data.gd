extends Node

var player_data_tres: Resource
onready var player_node: Node;
var personal_data: Dictionary;
var user_data: Dictionary;
var player_data_tres_path: String = "user://player_data_tres";

var MODE: int = -1;
var is_auto_acceleration_on: bool = false;

func _ready():
	load_data();

func change_headlights(headlights_color: String) -> void:
	personal_data["headlights_color"] = headlights_color;
	player_node.get_node("Sprite/LeftHeadlight").color = headlights_color;
	player_node.get_node("Sprite/RightHeadlight").color = headlights_color;
func change_underglow_light(underglow_light_color: String) -> void:
	personal_data["underglow_light_color"] = underglow_light_color;
	player_node.get_node("Sprite/UnderglowLight").color = underglow_light_color;
func change_sprite(id: String) -> void:
	var new_texture: StreamTexture = load("res://assets/images/sprites/%s.png" % id);
	player_node.get_node("Sprite").texture = new_texture;
	personal_data["sprite"] = id
func set_times_of_day(data: Dictionary) -> void:
	match data["id"]:
		0:
			for child in PlayerData.player_node.get_node("Sprite").get_children():
				child.visible = false;
		1:
			PlayerData.player_node.get_node("Sprite/LeftHeadlight").visible = false;
			PlayerData.player_node.get_node("Sprite/RightHeadlight").visible = false;
			PlayerData.player_node.get_node("Sprite/UnderglowLight").visible = true;
		2:
			for child in PlayerData.player_node.get_node("Sprite").get_children(): child.visible = true;

func load_data() -> void:
	if PlayerDataTres.data_exists(player_data_tres_path):
		player_data_tres = PlayerDataTres.load_data(player_data_tres_path) as PlayerDataTres;
	if player_data_tres == null:
		player_data_tres = PlayerDataTres.new();
		player_data_tres.save_data(player_data_tres_path);
	personal_data = player_data_tres.static_player_data["personal_data"];
	user_data = player_data_tres.static_player_data["user_data"];
func save_data() -> void:
	player_data_tres.static_player_data["personal_data"].merge(personal_data, true);
	player_data_tres.static_player_data["user_data"].merge(user_data, true);
	player_data_tres.save_data(player_data_tres_path);
