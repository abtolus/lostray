extends Control

onready var label: Label = $VBC/C/MC/VBC/Control/Label;
onready var email_address_le: LineEdit = $VBC/C/MC/VBC/EmailAddressLE;
onready var password_le: LineEdit = $VBC/C/MC/VBC/HBC2/PasswordLE;
onready var login_button: Button = $VBC/C/MC/VBC/HBC/Login;
onready var sign_up_curtain: ColorRect = $SignUpCurtain;

onready var sign_up_menu_tscn: PackedScene = load("res://ui/menu_container/supabase_menu/sign_up_menu.tscn")

onready var supabase_menu: Control = get_node("../..");

func handle_error(message: String = "", response: Dictionary = {}) -> void:
	if message != "":
		label.text = message
	elif response.get("result", HTTPRequest.RESULT_SUCCESS) != HTTPRequest.RESULT_SUCCESS:
		label.text = "Can't reach the server (result %d, code %d). Check your internet connection." % [response["result"], response.get("code", 0)]
	else: label.text = "Since the email address or password you entered is incorrect, please double-check your credentials."
	
func _on_SignUpB_button_up():
	supabase_menu.change_menu(sign_up_menu_tscn.instance());

func _on_Login_button_up():
	if email_address_le.text == "" or password_le.text == "": return;
	
	if not Supabase.is_valid_email(email_address_le.text):
		handle_error("Please enter a valid email address.")
		return
	elif password_le.text.length() < 8:
		handle_error("Password must contain at least 8 characters.")
		return
	
	sign_up_curtain.show();
	var response = yield(Supabase.login(email_address_le.text, password_le.text), "completed");
	
	if response.result != HTTPRequest.RESULT_SUCCESS or response.code != 200:
		sign_up_curtain.hide();
		handle_error("", response);
		return;
	
	yield(Supabase.cloud_save(), "completed");
	sign_up_curtain.hide();
	
	get_node("../AccountMenu").show();
	queue_free();
func _on_Back_button_up():
	supabase_menu.queue_free();

func _on_Visibility_toggled(button_pressed):
	password_le.secret = not button_pressed;
