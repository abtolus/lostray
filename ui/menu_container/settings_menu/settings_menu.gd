extends Control

onready var music_hs: HSlider = $Control/MC/ScrollContainer/VBC/Sound/HBC/MusicHS;
onready var sound_effects_hs: HSlider = $Control/MC/ScrollContainer/VBC/Sound/HBC2/SoundEffectsHS;
onready var option_button_tod: OptionButton = $Control/MC/ScrollContainer/VBC/Gameplay/TimesOfDay/OptionButtonTOD;
onready var option_button_crs: OptionButton = $Control/MC/ScrollContainer/VBC/Gameplay/CameraRotationSpeed/OptionButtonCRS;
onready var option_button_d: OptionButton = $Control/MC/ScrollContainer/VBC/Gameplay/Difficulty/OptionButtonD;
onready var button_sf: Button = $Control/MC/ScrollContainer/VBC/Gameplay/ShowFPS/ButtonSF;
onready var button_aa = $Control/MC/ScrollContainer/VBC/Gameplay/AutoAcceleration/ButtonAA;

func _ready():
	music_hs.value = GlobalData.settings_data["music_volume"]; sound_effects_hs.value = GlobalData.settings_data["sound_effects_volume"];
	option_button_tod.select(GlobalData.settings_data["times_of_day"]["id"]);
	option_button_crs.select(GlobalData.settings_data["camera_rotation_speed"]["id"]);
	option_button_d.select(GlobalData.settings_data["difficulty"]["id"]);
	button_sf.pressed = GlobalData.settings_data["show_fps"]; button_sf.set_text("On" if GlobalData.settings_data["show_fps"] == true else "Off");
	button_aa.pressed = GlobalData.settings_data["is_auto-acceleration_on"]; button_aa.set_text("On" if GlobalData.settings_data["is_auto-acceleration_on"] == true else "Off");
	GlobalTscn.fps_label.get_parent().visible = button_sf.pressed;

func _on_Back_button_up():
	queue_free();

func _on_MusicHS_value_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(value / 100.0));
	GlobalData.settings_data["music_volume"] = value;
func _on_SoundEffectsHS_value_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound effects"), linear2db(value / 100.0))
	GlobalData.settings_data["sound_effects_volume"] = value;
func _on_ButtonSF_toggled(button_pressed: bool):
	button_sf.set_text("On" if button_pressed == true else "Off");
	GlobalData.settings_data["show_fps"] = button_pressed;
	GlobalTscn.fps_label.get_parent().visible = button_pressed;

func _on_OptionButtonTOD_item_selected(index):
	var text: String = option_button_tod.get_item_text(index);
	var data: Dictionary = {"canvas_modulate": get_times_of_day(text), "id": index};
	GlobalData.settings_data["times_of_day"] = data;
	var directional_light: CanvasModulate = get_tree().current_scene.main.get_node("DirectionalLight");
	directional_light.color = Color(GlobalData.settings_data["times_of_day"]["canvas_modulate"]);
	PlayerData.set_times_of_day(GlobalData.settings_data["times_of_day"]);

func get_times_of_day(text) -> String:
	match text:
		"Daytime": return "d6d6d6"; "Twilight": return "909090";
		"Nighttime": return "404040";  _: return "d6d6d6";

func _on_OptionButtonCRS_item_selected(index):
	var text: String = option_button_crs.get_item_text(index);
	var data: Dictionary = {"value": get_camera_rotation_speed(text), "id": index};
	GlobalData.settings_data["camera_rotation_speed"] = data;
func get_camera_rotation_speed(text) -> float:
	match text:
		"Low": return 5.0; "Mid-low": return 6.25; "Normal": return 7.5;
		"Mid-high": return 8.75; "High": return 10.0; _: return 10.0;

func _on_OptionButtonD_item_selected(index):
	var text: String = option_button_d.get_item_text(index);
	var data: Dictionary = {"value": text, "id": index};
	GlobalData.settings_data["difficulty"] = data;
func _on_ButtonAA_toggled(button_pressed):
	button_aa.set_text("On" if button_pressed == true else "Off");
	GlobalData.settings_data["is_auto-acceleration_on"] = button_pressed;
	PlayerData.is_auto_acceleration_on = button_pressed;
