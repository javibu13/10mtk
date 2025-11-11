extends Node

@export var vbox_container_print: VBoxContainer
var http_request: HTTPRequest 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NetworkManager.server_print_msg.connect(_on_server_print)
	print("Server working ⚙️...")
	_on_server_print("Server working ⚙️...")
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_server_print(msg: String):
	var new_label := Label.new()
	new_label.text = msg
	vbox_container_print.add_child(new_label)


# Test function to send email using SendGrid API
func _send_email():
	# Build request body for SendGrid API
	var body = {
		"personalizations": [{
			"to": [{"email": "test@test.com"}],
			"subject": "Godot Test"
		}],
		"from": {"email": "test@test.com"},
		"content": [{
			"type": "text/plain",
			"value": "New Password:\n????"
		}]
	}
	# Needed headers for SendGrid
	var headers = [
		"Authorization: Bearer " + "APIKEY",
		"Content-Type: application/json"
	]
	# Realizar la petición
	var json_body = JSON.stringify(body)
	var response = http_request.request("https://api.sendgrid.com/v3/mail/send", headers, HTTPClient.METHOD_POST, json_body)
	if response != OK:
		print("ERROR SENDING EMAIL")


func _is_valid_email(email: String) -> bool:
	# Basic email validation
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
	return regex.search(email) != null


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if response_code == 202:
		print("SUCCESSFUL EMAIL!!")
	else:
		var response_text = body.get_string_from_utf8()
		print("Error response: ", response_text)
