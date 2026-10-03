extends Control

onready var last_cloud_sync_l = $MenuManager/AccountMenu/VBC/C/MC/VBC/C2/LastCloudSyncL;
onready var menu_manager = $MenuManager;
onready var sign_up_menu_tscn: PackedScene = preload("res://ui/menu_container/supabase_menu/sign_up_menu.tscn");
onready var sign_up_curtain = $MenuManager/AccountMenu/SignUpCurtain;

func _ready() -> void:
	var file = File.new()
	if PlayerData.user_data["authentication_token"] in ["", null] or file.file_exists("user://signup.json"): return;
	last_cloud_sync_l.text = "Last Cloud Sync: %s" % PlayerData.user_data.last_cloud_sync;
	for child in menu_manager.get_children():
		if not child.name in ["AccountMenu"]: child.queue_free();
	menu_manager.get_node("AccountMenu").show();
	
func change_menu(target_menu: Control) -> void:
	for child in menu_manager.get_children():
		if not child.name in ["AccountMenu"]: child.queue_free();
	menu_manager.add_child(target_menu);
func _on_Load_button_up():
	sign_up_curtain.show();
	var datetime: Dictionary = OS.get_datetime();
	var formatted_datetime: String = "%02d:%02d - %02d/%02d/%04d" % [datetime.hour, datetime.minute, datetime.day, datetime.month, datetime.year]
	PlayerData.user_data["last_cloud_sync"] = formatted_datetime;
	
	var success = yield(Supabase.cloud_load(), "completed");
	if not success: print("Cloud load failed")
	queue_free();
func _on_Save_button_up():
	sign_up_curtain.show();
	var datetime: Dictionary = OS.get_datetime();
	var formatted_datetime: String = "%02d:%02d - %02d/%02d/%04d" % [datetime.hour, datetime.minute, datetime.day, datetime.month, datetime.year]
	PlayerData.user_data["last_cloud_sync"] = formatted_datetime;
	
	var saved = yield(Supabase.cloud_save(last_cloud_sync_l), "completed");
	if not saved: print("Cloud save failed")
	queue_free();

func _on_Delete_button_up():
	sign_up_curtain.show(); sign_up_curtain.get_node("MC").show();

func _on_Back_button_up():
	queue_free();

func _on_No_button_up():
	sign_up_curtain.get_node("MC").hide(); sign_up_curtain.hide();

func _on_Yes_button_up():
	sign_up_curtain.get_node("MC").hide();
	var response = yield(Supabase.delete_user(), "completed");
	if response.result != HTTPRequest.RESULT_SUCCESS or response.get("code", 200) >= 400:
		print("Unable to delete the account."); return;
	GlobalData.clear_data();
	PlayerData.load_data();
	
	get_tree().current_scene.emit_signal("RefreshMainMenu");
	
	get_parent().get_node("MainMenuUI").username_edition.visible = true;
	get_parent().get_node("MainMenuUI").cancel_button.visible = false;
	queue_free();
