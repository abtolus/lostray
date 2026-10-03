extends CanvasLayer

#CONFIGURATION
var prologue_file_path: String = "res://assets/json/prologueLTN.txt";
var prologue_images: Array = [
	preload("res://assets/images/general/prologueLTNp1.png"),
	preload("res://assets/images/general/prologueLTNp2.png"),
	preload("res://assets/images/general/prologueLTNp3.png"),
	preload("res://assets/images/general/prologueLTNp4.png")
];
#NODES
onready var texture_rect: TextureRect = $TR;
onready var subtext:  = $RTL;
onready var animation: AnimationPlayer = $AP;
onready var tween: Tween = $TW;

#VARIABLES
var prologue_index: int = 0;
var prologue_paragraphs: Array = [];
var is_typing: bool = false;

func _ready():
	subtext.bbcode_enabled = true;
	_load_prologue(prologue_file_path);
	if prologue_paragraphs.size() > 0:
		update();
	animation.play_backwards("fade_to_black");
func _load_prologue(path):
	var file: File = File.new();
	if file.file_exists(path):
		file.open(path, File.READ);
		while not file.eof_reached():
			var sentence: String = file.get_line().strip_edges();
			if sentence != "":
				prologue_paragraphs.append(sentence);
		file.close();
	else: printerr("File is not found at " + path);
func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		if is_typing: finish_typing_early();
		else: advance();
func finish_typing_early():
	tween.stop_all();
	subtext.visible_characters = -1;
	is_typing = false;
func advance():
	if prologue_index < prologue_paragraphs.size() - 1:
		prologue_index += 1;
		update();
	else: end_prologue();
func update():
	var image_index: int = int(prologue_index / 3.0);
	if prologue_index % 3 == 0:
		#ADVANCE IMAGE
		texture_rect.texture = prologue_images[image_index];
	#ADVANCE SUBTEXT
	subtext.bbcode_text = prologue_paragraphs[prologue_index];
	subtext.visible_characters = 0;
	is_typing = true;
	#DRAMATIC TYPEWRITER EFFECT
	var duration: int = prologue_paragraphs[prologue_index].length() * 0.02;
	tween.interpolate_property(subtext, "visible_characters", 0, prologue_paragraphs[prologue_index].length(), duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT);
	tween.start();
func end_prologue():
	animation.play("fade_to_black");
	yield(animation, "animation_finished");
	get_parent().get_node("UI/MainMenuUI").username_edition.visible = true;
	get_parent().get_node("UI/MainMenuUI").cancel_button.visible = false;
	queue_free();
func _on_TW_tween_completed(_object, _key):
	is_typing = false;
	#VIBRATE
	if OS.get_name() == "Android":
		Input.vibrate_handheld(50);
