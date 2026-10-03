extends Control

onready var init_ap: Node = $InitAP;

func _ready():
	init_ap.play("_init");
