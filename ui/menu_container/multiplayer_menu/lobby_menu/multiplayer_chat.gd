extends Control

onready var message_box: Node = $MC/VBC/MessageBox;
onready var message_line_edit: Node = $MC/VBC/HBC/MessageLineEdit;

func _physics_process(_delta):
	if GlobalNodes.get_children().size() < 1:
		message_box.set_text("");

remotesync func send(message: String, username: String) -> void:
	message_box.text += " %s: %s\n" % [username, message];
	message_box.scroll_vertical = INF;

func _on_Send_button_up():
	if message_line_edit.text == "":
		return;
	rpc("send", message_line_edit.text, PlayerData.personal_data["name"]);
	message_line_edit.text = "";
