extends Node

## Stores the IDs of clients that have been logged in and their basic user info
## [codeblock]
## {
##	471290087: {
##				user_name: "Montse",
##				nickname: "mgoon13".
##				email: "false@email.tk"
##				},
##	1416429352: {
##				user_name: "Javier",
##				nickname: "Javibu13".
##				email: "superfalse@email.tk"
##				}
## }
## [/codeblock]
var logged_in_users: Dictionary[int, Dictionary] = {}
var http_request: HTTPRequest = HTTPRequest.new()
var config_reader = ConfigFile.new()
var api_email := {}


func _ready() -> void:
	_read_config_file()


# Used to read the config file with important data to setup and private info/keys
func _read_config_file():
	# TODO: Change path by "user://" for production env
	var result = config_reader.load("res://.env.cfg")
	if result != OK:
		push_error("Config file not found")
		return
	api_email.key = config_reader.get_value("api", "email_key", "")
	api_email.secret = config_reader.get_value("api", "email_secret", "")
	api_email.url = config_reader.get_value("api", "email_url", "")
	api_email.sender_email = config_reader.get_value("api", "email_sender_email", "")
	api_email.sender_name = config_reader.get_value("api", "email_sender_name", "")
	if api_email.key == "":
		push_error("Email API key not found in config file")
	if api_email.secret == "":
		push_error("Email API secret not found in config file")
	if api_email.url == "":
		push_error("API URL not found in config file")
	if api_email.sender_email == "":
		push_error("API sender email not found in config file")
	if api_email.sender_name == "":
		push_error("API sender name not found in config file")


# Send email using External API to user who asked for password reset
func send_reset_password_email(user_email: String, user_name: String, new_password: String) -> bool:
	# Build request body for SendGrid API
	#var body = {
		#"personalizations": [{
			#"to": [{"email": to}],
			#"subject": "10' To Kill - Account Password Reset"
		#}],
		#"from": {"email": api_email.sender},
		#"content": [{
			#"type": "text/plain",
			#"value": "10' To Kill\n\nNew Password:\n" + new_password
		#}]
	#}
	# Needed headers for SendGrid
	#var headers = [
		#"Authorization: Bearer " + api_email.key,
		#"Content-Type: application/json"
	#]
	# Build request body for Mailjet API v3.1
	var body = {
		"SandboxMode": false,
		"Messages": [
			{
				"From": {
					"Email": api_email.sender_email,
					"Name": api_email.sender_name
				},
				"To": [
					{
						"Email": user_email,
						"Name": user_name
					}
				],
				"Subject": "10' To Kill - Password Reset",
				"TextPart": "10' To Kill\n\nNew Password:\n" + new_password
			}
		]
	}
	# Needed headers for Mailjet API v3.1
	var auth_raw = api_email.key + ":" + api_email.secret
	var auth_bytes = auth_raw.to_utf8_buffer()
	var auth_token = Marshalls.raw_to_base64(auth_bytes)
	var headers = [
		"Authorization: Basic " + auth_token,
		"Content-Type: application/json"
	]
	# Execute http request
	var json_body = JSON.stringify(body)
	var response = http_request.request(api_email.url, headers, HTTPClient.METHOD_POST, json_body)
	if response != OK:
		print("ERROR SENDING EMAIL: ", response)
		NetworkManager.server_print_msg.emit("ERROR SENDING EMAIL: " + str(response))
		return false
	# Wait for request completed
	var response_completed = await http_request.request_completed
	NetworkManager.server_print_msg.emit(str(response_completed))
	# response = [result, response_code, headers, body]
	var response_completed_result = response_completed[0]
	var response_completed_response_code = response_completed[1]
	
	if response_completed_result == HTTPRequest.RESULT_SUCCESS and (response_completed_response_code == 200 || response_completed_response_code == 201 || response_completed_response_code == 202):
		print("SUCCESSFUL EMAIL!!")
		NetworkManager.server_print_msg.emit("SUCCESSFUL EMAIL!!")
		return true
	else:
		var response_text = response_completed[3].get_string_from_utf8()
		print("Error response: ", response_text)
		NetworkManager.server_print_msg.emit("Error response: " + str(response_text))
		return false
