extends CanvasLayer

onready var multiplayer_main: Node = get_node("..");
onready var multiplayer_status = $CUI/MultiplayerStatus;
onready var speedrun_label = $TUI/SpeedrunLabel;
onready var cui = $CUI; onready var tui = $TUI;
onready var tsb_accelerate = $CUI/Inputs/TSBAccelerate;

func _ready():
	tsb_accelerate.visible = false if PlayerData.is_auto_acceleration_on else true;
	multiplayer_main.connect("RefreshMUI", self, "refresh_multiplayer_ui");

func refresh_multiplayer_ui() -> void:
	multiplayer_status.refresh();

func _physics_process(_delta):
	speedrun_label.set_text(GlobalData.get_time(multiplayer_main.unix_time));
