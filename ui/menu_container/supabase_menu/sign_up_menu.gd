extends Control

const SIGNUP_PATH: String = "user://signup.json"
const EXPIRATION: int = 3600

onready var label = $VBC/C/MC/VBC/Control/Label
onready var email_address_le: LineEdit = $VBC/C/MC/VBC/EmailAddressLE
onready var otp_code_le: LineEdit = $VBC/C/MC/VBC/OTPCodeLE
onready var password_le: LineEdit = $VBC/C/MC/VBC/HBC2/PasswordLE
onready var visibility_button: TextureButton = $VBC/C/MC/VBC/HBC2/C/CR/Visibility;
onready var next_button: Button = $VBC/C/MC/VBC/HBC/Next
onready var back_button: Button = $VBC/C/MC/VBC/HBC/Back
onready var reset_button = $VBC/C/MC/VBC/HBC/Reset
onready var sign_up_curtain: ColorRect = $SignUpCurtain

onready var login_menu_tscn: PackedScene = preload("res://ui/menu_container/supabase_menu/login_menu.tscn")
onready var supabase_menu: Control = get_node("../..")

func _ready() -> void:
	restore_signup()

func restore_signup() -> void:
	var file = File.new()
	if not file.file_exists(SIGNUP_PATH):
		return
	
	if file.open(SIGNUP_PATH, File.READ) == OK:
		var parsed = JSON.parse(file.get_as_text())
		file.close()
		if parsed.error != OK or not (parsed.result is Dictionary):
			return
		
		var data: Dictionary = parsed.result
		var saved_email: String = data.get("email", "")
		var saved_otp: String = data.get("otp", "")
		var step: String = data.get("step", "")
		var expired_at: int = data.get("expired_at", 0)
		
		if saved_email == "": return
		
		Supabase.email_address = saved_email
		email_address_le.text = saved_email
		otp_code_le.text = saved_otp
		
		if step == "otp":
			if OS.get_unix_time() < expired_at:
				email_address_le.editable = false
				otp_code_le.editable = true
				label.text = "A verification code has been sent to your email address and expires in 1 hour."
				back_button.hide()
			else:
				clear_signup()
				email_address_le.editable = true
				otp_code_le.editable = false
				label.text = "Since your verification code has expired, please request a new one."
		elif step == "password":
			if data.has("access_token") and data.get("access_token") != "":
				PlayerData.user_data["authentication_token"] = data.get("access_token")
			email_address_le.editable = false
			otp_code_le.editable = false
			password_le.editable = true; visibility_button.disabled = false;
			label.text = "Password must contain at least one uppercase letter, lowercase letter, number, and special character."

func save_signup(step: String, email: String, otp: String = "") -> void:
	var data = {
		"step": step,
		"email": email,
		"otp": otp,
		"expired_at": OS.get_unix_time() + EXPIRATION,
		"access_token": PlayerData.user_data.get("authentication_token", "")
	}
	var file = File.new()
	if file.open(SIGNUP_PATH, File.WRITE) == OK:
		file.store_string(JSON.print(data))
		file.close()

func clear_signup() -> void:
	var dir = Directory.new()
	if dir.file_exists(SIGNUP_PATH):
		dir.remove(SIGNUP_PATH)

func _on_LoginB_button_up():
	supabase_menu.change_menu(login_menu_tscn.instance())

func handle_error(message: String = "", response: Dictionary = {}) -> void:
	if message != "":
		label.text = message
	elif response.get("result", HTTPRequest.RESULT_SUCCESS) != HTTPRequest.RESULT_SUCCESS:
		label.text = "Can't reach the server (result %d, code %d). Check your internet connection." % [response["result"], response.get("code", 0)]
	elif otp_code_le.editable:
		label.text = "As the OTP code is invalid, check your mail and try one more time."
	else:
		label.text = "Something went wrong."

func _on_Next_button_up():
	if email_address_le.editable and email_address_le.text != "":
		if not Supabase.is_valid_email(email_address_le.text):
			handle_error("Please enter a valid email address.")
			return
		sign_up_curtain.show()
		
		var response = yield(Supabase.verify_email_address(email_address_le.text), "completed")
		sign_up_curtain.hide()
		
		if response.result != HTTPRequest.RESULT_SUCCESS or response.code >= 400:
			handle_error("", response)
			return
			
		save_signup("otp", email_address_le.text)
		otp_code_le.editable = true
		email_address_le.editable = false
		label.text = "A verification code has been sent to your email address and expires in 1 hour."
		back_button.hide()
		return
		
	elif otp_code_le.editable and otp_code_le.text != "":
		sign_up_curtain.show()
		var response = yield(Supabase.verify_otp_code(otp_code_le.text), "completed")
		sign_up_curtain.hide()
		
		if response.result != HTTPRequest.RESULT_SUCCESS or response.code >= 400:
			handle_error("", response)
			return
			
		save_signup("password", email_address_le.text, otp_code_le.text)
		password_le.editable = true; visibility_button.disabled = false;
		otp_code_le.editable = false
		label.text = "Password must contain at least one uppercase letter, lowercase letter, number, and special character."
		
	elif password_le.editable and password_le.text != "":
		if password_le.text.length() < 8:
			handle_error("Password must contain at least 8 characters.")
			return
			
		sign_up_curtain.show()
		var response = yield(Supabase.verify_password(password_le.text), "completed")
		
		if response.result != HTTPRequest.RESULT_SUCCESS or response.code >= 400:
			handle_error("", response)
			return
			
		clear_signup()
		yield(Supabase.cloud_save(), "completed")
		get_node("../AccountMenu").show()
		queue_free()

func _on_Back_button_up():
	supabase_menu.queue_free()

func _on_Reset_button_up():
	sign_up_curtain.show()
	if email_address_le.text != "":
		yield(Supabase.reset_user(email_address_le.text), "completed");
	clear_signup();
	Supabase.email_address = ""
	if PlayerData.user_data.has("authentication_token"):
		PlayerData.user_data["authentication_token"] = "";
	email_address_le.text = ""; otp_code_le.text = ""; password_le.text = "";
	email_address_le.editable = true; otp_code_le.editable = false; password_le.editable = false; visibility_button.disabled = true;
	back_button.show();
	label.text = "Enter your email address to receive a verification code.";
	sign_up_curtain.hide();

func _on_Visibility_toggled(button_pressed):
	password_le.secret = not button_pressed;
