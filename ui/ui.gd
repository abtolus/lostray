class_name UI
extends CanvasLayer

onready var main: Node = get_parent();
onready var cui: Node = $CUI; onready var tui: CanvasLayer = $TUI;
onready var database: TextureProgress = $CUI/Database;
onready var speedrun_label: Label = $TUI/SpeedrunLabel;
onready var tsb_accelerate = $CUI/Inputs/TSBAccelerate;

func _ready() -> void:
	tsb_accelerate.visible = false if PlayerData.is_auto_acceleration_on else true;
	main.connect("RefreshUI", self, "refresh_ui");

func _physics_process(_delta):
	if get_tree().current_scene.name == "MainMenu": return;
	speedrun_label.set_text(GlobalData.get_time(main.unix_time));
#func do_power_supply(value: int) -> void:
#	if power_supply.value + value > 100: return;
#	power_supply.value += value;
func refresh_ui() -> void:
	var array: Array = PlayerData.player_node.database;
	if array.size() < 1:
		database.get_node("Label").set_text(""); database.value = 0;
		return;
	var string: String = array[0];
	for i in range(array.size()):
		if not i == 0:
			string += "," + str(array[i])
	database.get_node("Label").set_text(string);
	database.value = array.size();
func _on_PauseButton_button_up() -> void:
	load_pause_menu();
func load_pause_menu() -> void:
	main.is_playing = false; GlobalNodes.is_paused = true; # Make the main stop processing
	GlobalData.change_visibility([cui, tui], [false, false]); # Also hide the speedrun timer
	GlobalData.instantiate_node(load("res://ui/menu_container/single_player_menu/pause_menu/pause_menu.tscn"), self);
