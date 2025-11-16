extends Node


signal register_user_end(success, message)


# Request for server to create new user
@rpc("any_peer", "call_remote", "reliable")
func server_register_user(nickname: String, email: String, password_hash: String):
	if not multiplayer.is_server():
		return
	# Get the ID of the client who requested the creation of the user
	var client_id := multiplayer.get_remote_sender_id()
	# Validate data sent from client
	var validation_error := _validate_user_register_data(nickname, email, password_hash)
	if not validation_error.is_empty():
		var error_message = "❌ Invalid data for user creation (" + validation_error + ")"
		NetworkManager.server_print_msg.emit(error_message)
		client_register_response.rpc_id(client_id, false, error_message)
		return
	# Validate if nickname already exists
	var existing_nickname = DatabaseManager.player_get_by_nickname(nickname)
	if not existing_nickname.is_empty():
		var error_message = "❌ Nickname is not available"
		NetworkManager.server_print_msg.emit(error_message)
		client_register_response.rpc_id(client_id, false, error_message)
		return
	# Validate if email already exists
	var existing_email = DatabaseManager.player_get_by_email(email)
	if not existing_email.is_empty():
		var error_message = "❌ Email is already registered"
		NetworkManager.server_print_msg.emit(error_message)
		client_register_response.rpc_id(client_id, false, error_message)
		return
	# Create user in database
	var player_id = DatabaseManager.player_create_new(nickname, email, password_hash)
	if player_id == -1:
		var error_message = "❌ Error during user creation"
		NetworkManager.server_print_msg.emit(error_message)
		client_register_response.rpc_id(client_id, false, error_message)
		return
	# Send notification to client
	client_register_response.rpc_id(client_id, true, "✅ User registered!")


# Validate data for new user creation
func _validate_user_register_data(nickname: String, email: String, password_hash: String) -> String:
	var errors: Array = []
	# Validate Nickname
	var nickname_regex = RegEx.create_from_string("^[a-zA-Z0-9_ ]{1,16}$")
	if nickname.is_empty() or nickname_regex.search(nickname) == null:
		errors.append("Invalid nickname")
	# Validate Email
	var email_regex = RegEx.create_from_string("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
	if email.is_empty() or email_regex.search(email) == null:
		errors.append("Invalid email")
	# Validate Password HASH (SHA-256 = 64 characters)
	if password_hash.length() != 64:
		errors.append("Invalid password")
	return ", ".join(errors)


@rpc("authority", "call_remote", "reliable")
func client_register_response(success: bool, message: String):
	register_user_end.emit(success, message)
