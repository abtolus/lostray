extends ControlDevice

onready var main: Node = get_node("../..");
onready var area: Area2D = $SafeZone;
onready var sprites = $Sprites;
onready var cui: Node = main.get_node("UI/CUI");

var textures: Array = ["res://assets/images/sprites/quadrant_empty.png", "res://assets/images/sprites/quadrant_finished.png", "res://assets/images/sprites/quadrant_hacked.png"];
var body_: Node;
const hint: String = "Enter the encrypted 16-digit code";
const hint_text: String = "+2 = (2+1)2 = 32\n3+ = 3(3+1) = 34\n-8 = (8-1)8 = 78\n9- = 9(9-1) = 98";

func _ready():
	main.connect("RefreshMain", self, "refresh");
	attempt_to_deactivate();
func refresh() -> void:
	var control_devices: Node2D = main.get_node("ControlDevices");
	for quadrant in control_devices.get_children():
		if quadrant.is_in_group("quadrant") and quadrant is Node2D:
			if quadrant.name.to_lower() in main.finished_quadrants: sprites.get_node(quadrant.name).get_node("Sprite").set_texture(load(textures[1]));
			elif quadrant.name.to_lower() in main.hacked_quadrants: sprites.get_node(quadrant.name).get_node("Sprite").set_texture(load(textures[2]));
			else: sprites.get_node(quadrant.name).get_node("Sprite").set_texture(load(textures[0]));

func attempt_to_activate() -> void:
	var style_box = area.get_node("Panel").get_stylebox("panel");
	style_box.border_color = Color("ff00c000"); state = 1;
func attempt_to_deactivate() -> void:
	var style_box = area.get_node("Panel").get_stylebox("panel");
	style_box.border_color = Color("ffc0c0c0"); state = 0;

func attempt_to_receive() -> void:
	if body_ == null: return;
	if body_.database.size() < 1:
		var style_box = area.get_node("Panel").get_stylebox("panel");
		style_box.border_color = Color("ffc00000");
		var tween: SceneTreeTween = create_tween();
		tween.tween_property(area.get_node("Panel").get_stylebox("panel"), "border_color", Color("ffc0c0c0"), 2.0)
		return;
	if not GlobalTscn.has_node("MenuLayer/TabletMenu"):
		main.is_playing = false; # Make the main stop processing
		var question: String = body_.database[randi() % body_.database.size()];
		var solution: String = get_decrypted_database(question);
		load_tablet_menu(self, [[solution], question]);
func receive() -> void:
	attempt_to_deactivate();
	main.is_playing = false;
	main.finish_quadrant();

func get_decrypted_database(encrypted_data: String) -> String:
	var decrypted_data: String = "";
	if encrypted_data[0] == "+":
		decrypted_data = encrypted_data.replace("+", str(int(encrypted_data[1]) + 1));
	elif encrypted_data[1] == "+":
		decrypted_data = encrypted_data.replace("+", str(int(encrypted_data[0]) + 1));
	elif encrypted_data[0] == "-":
		decrypted_data = encrypted_data.replace("-", str(int(encrypted_data[1]) - 1));
	elif encrypted_data[1] == "-":
		decrypted_data = encrypted_data.replace("-", str(int(encrypted_data[0]) - 1));
	return decrypted_data;

func _on_SafeZone_body_entered(body: Node):
	if not body.is_in_group("player"): return;
	body_ = body;
func _on_SafeZone_body_exited(body: Node):
	if body_ == body: body_ = null;
