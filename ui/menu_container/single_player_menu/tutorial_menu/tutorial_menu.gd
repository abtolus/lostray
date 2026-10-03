extends Control

onready var control: Control = $C/Control;
onready var pages: Array = ["res://ui/menu_container/single_player_menu/tutorial_menu/tutorial_components/tutorial_introduction.tscn",
"res://ui/menu_container/single_player_menu/tutorial_menu/tutorial_components/tutorail_transmitters.tscn"];
var current_page: int = 0;

func _ready():
	load_tutorial_page();

func load_tutorial_page() -> void:
	for i in control.get_children():
		i.queue_free();
	GlobalData.instantiate_node(load(pages[current_page]), control);

func _on_TBL_button_up():
	if current_page == 0: current_page = pages.size() - 1;
	else: current_page -= 1;
	load_tutorial_page();
func _on_TBR_button_up():
	if current_page == pages.size() - 1: current_page = 0;
	else: current_page += 1;
	load_tutorial_page();

func _on_Back_button_up():
	queue_free();
