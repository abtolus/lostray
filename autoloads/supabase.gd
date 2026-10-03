extends Node

const URL: String = "https://bright-wolverine-1908.abtolus.deno.net"
const KEY: String = "sb_publishable_4bYq55g9GxW3g7x68hiKvA_EcApdqRi"

const AUTH_KEYS: Array = ["authentication_token", "refresh_token", "id"]

var email_address: String = ""

func is_valid_email(email: String) -> bool:
	var regex := RegEx.new()
	regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");
	return regex.search(email) != null;

func verify_email_address(email: String) -> Dictionary:
	email_address = email
	var body = JSON.print({"email": email, "create_user": true})
	return yield(_request("/auth/v1/otp", body), "completed")

func verify_otp_code(otp_code: String) -> Dictionary:
	var body = JSON.print({"email": email_address, "token": otp_code, "type": "email"})
	var response = yield(_request("/auth/v1/verify", body), "completed")
	process_session(response)
	return response

func verify_password(password: String) -> Dictionary:
	var body = JSON.print({"password": password})
	var response = yield(_request("/auth/v1/user", body, HTTPClient.METHOD_PUT), "completed")
	process_session(response)
	return response

func login(email: String, password: String) -> Dictionary:
	email_address = email
	var body = JSON.print({"email": email, "password": password})
	var response = yield(_request("/auth/v1/token?grant_type=password", body), "completed")
	process_session(response)
	return response

func reset_user(email: String) -> Dictionary:
	var body = JSON.print({"user_email": email})
	var response = yield(_request("/rest/v1/rpc/reset_user", body, HTTPClient.METHOD_POST), "completed");
	return response;

func delete_user() -> Dictionary:
	var response = yield(_request("/rest/v1/rpc/delete_user", "{}", HTTPClient.METHOD_POST), "completed");
	if response.result == HTTPRequest.RESULT_SUCCESS and response.get("code", 200) < 400:
		PlayerData.user_data.clear(); email_address = ""
	return response;

func refresh_token() -> Dictionary:
	var body = JSON.print({"refresh_token": PlayerData.user_data.get("refresh_token", "")})
	var response = yield(_request("/auth/v1/token?grant_type=refresh_token", body), "completed")
	process_session(response)
	return response

func process_session(response: Dictionary) -> void:
	if response.code != 200: return
	
	var body = response.body_parsed
	if not (body is Dictionary): return
	
	if body.has("access_token"):
		PlayerData.user_data["authentication_token"] = body["access_token"]
	if body.has("refresh_token"):
		PlayerData.user_data["refresh_token"] = body["refresh_token"]
	if body.has("user") and body["user"] is Dictionary:
		PlayerData.user_data["id"] = body["user"].get("id")
	elif body.has("id"):
		PlayerData.user_data["id"] = body.get("id")

func need_user_token(path: String) -> bool:
	return path.begins_with("/rest/v1") or path.begins_with("/auth/v1/user")

func _request(path: String, body = "", method = HTTPClient.METHOD_POST, extra_headers: Array = []) -> Dictionary:
	var http = HTTPRequest.new()
	add_child(http)
	
	var headers = [
		"Content-Type: application/json",
		"apikey: " + KEY
	]
	
	var token = PlayerData.user_data.get("authentication_token", "")
	if token is String and token != "" and need_user_token(path):
		headers.append("Authorization: Bearer " + token)
		
	for header in extra_headers:
		headers.append(header)
	
	var err = http.request(URL + path, headers, true, method, body)
	if err != OK:
		http.queue_free()
		yield(get_tree(), "idle_frame")
		return {"result": HTTPRequest.RESULT_CANT_CONNECT, "code": 0, "body_parsed": null}
	
	var response = yield(http, "request_completed")
	http.queue_free()
	
	var response_dictionary = {
		"result": response[0],
		"code": response[1],
		"body_parsed": null
	}
	if response[3].size() > 0:
		var parsed = JSON.parse(response[3].get_string_from_utf8())
		if parsed.error == OK: response_dictionary["body_parsed"] = parsed.result
	return response_dictionary

func cloud_save(last_cloud_sync_l: Label = null) -> bool:
	yield(get_tree(), "idle_frame")
	
	var token = PlayerData.user_data.get("authentication_token", "")
	var user_id = PlayerData.user_data.get("id", "")
	if not (token is String) or not (user_id is String) or token == "" or user_id == "":
		if last_cloud_sync_l: last_cloud_sync_l.text = "Sync failed"
		return false
	
	var clean_user_data: Dictionary = PlayerData.user_data.duplicate()
	for key in AUTH_KEYS:
		clean_user_data.erase(key)
	
	var data: Dictionary = {
		"id": user_id,
		"personal_data": PlayerData.personal_data,
		"user_data": clean_user_data
	}
	var request = yield(_request(
		"/rest/v1/users", 
		JSON.print(data),
		HTTPClient.METHOD_POST,
		["Prefer: resolution=merge-duplicates"]
	), "completed")
	var success = (request.result == HTTPRequest.RESULT_SUCCESS and request.code in [200, 201, 204])
	if last_cloud_sync_l:
		last_cloud_sync_l.text = "Synced successfully" if success else "Sync failed"
	return success

func cloud_load() -> bool:
	yield(get_tree(), "idle_frame")
	
	var user_id = PlayerData.user_data.get("id", "")
	if not (user_id is String) or user_id == "": return false
	
	var request = yield(_request(
		"/rest/v1/users?id=eq." + user_id + "&select=personal_data,user_data",
		"", HTTPClient.METHOD_GET
	), "completed")
	
	if request.result != HTTPRequest.RESULT_SUCCESS or request.code != 200: return false
	
	var data_array = request.body_parsed
	if not (data_array is Array) or data_array.size() == 0: return false
	
	var fetched_data = data_array[0]
	
	var cloud_personal = fetched_data.get("personal_data")
	if cloud_personal is Dictionary:
		for key in cloud_personal:
			PlayerData.personal_data[key] = cloud_personal[key]
	var cloud_user = fetched_data.get("user_data")
	if cloud_user is Dictionary:
		for key in cloud_user:
			if not (key in AUTH_KEYS):
				PlayerData.user_data[key] = cloud_user[key]
	
	if get_tree().current_scene.has_signal("RefreshMainMenu"): get_tree().current_scene.emit_signal("RefreshMainMenu")
	return true
