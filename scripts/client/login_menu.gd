extends Control

const login_menu_theme = preload("res://themes/login_menu.theme")

var server_timeout: float = 5.0
var accept_dialog: AcceptDialog = AcceptDialog.new()
var confirm_dialog: ConfirmationDialog = ConfirmationDialog.new()

@onready var trying_to_connect_container: VBoxContainer = $TryingToConnect_VBoxContainer
@onready var connection_failed_container: VBoxContainer = $ConnectionFailed_VBoxContainer
@onready var login_container: VBoxContainer = $Login_VBoxContainer
@onready var forgot_your_password_container: VBoxContainer = $ForgotYourPassword_VBoxContainer
@onready var login_button: Button = $Login_VBoxContainer/LoginRegister_VBoxContainer/Login_Button
@onready var register_container: VBoxContainer = $Register_VBoxContainer
@onready var try_again_button: Button = $ConnectionFailed_VBoxContainer/TryAgain_Button
@onready var forgot_your_password_text_button: RichTextLabel = $Login_VBoxContainer/PasswordGroup_VBoxContainer/ForgotPassword_RichTextLabel
@onready var reset_password_button: Button = $ForgotYourPassword_VBoxContainer/ButtonsGroup_VBoxContainer/Reset_Button
@onready var return_from_forgot_your_password_button: Button = $ForgotYourPassword_VBoxContainer/ButtonsGroup_VBoxContainer/Return_Button
@onready var email_login_line_edit: LineEdit = $Login_VBoxContainer/Email_LineEdit
@onready var password_login_line_edit: LineEdit = $Login_VBoxContainer/PasswordGroup_VBoxContainer/Password_LineEdit
@onready var email_forgot_your_password_line_edit: LineEdit = $ForgotYourPassword_VBoxContainer/Email_LineEdit
@onready var register_now_login_text_button: RichTextLabel = $Login_VBoxContainer/LoginRegister_VBoxContainer/ForgotPassword_RichTextLabel
@onready var return_from_register_button: Button = $Register_VBoxContainer/ButtonsGroup_VBoxContainer/Return_Button
@onready var register_button: Button = $Register_VBoxContainer/ButtonsGroup_VBoxContainer/Register_Button
@onready var nickname_register_line_edit: LineEdit = $Register_VBoxContainer/NicknameGroup_VBoxContainer2/Nickname_LineEdit
@onready var nickname_validation_register_text: RichTextLabel = $Register_VBoxContainer/NicknameGroup_VBoxContainer2/NicknameValidationText_RichTextLabel
@onready var email_register_line_edit: LineEdit = $Register_VBoxContainer/EmailGroup_VBoxContainer/Email_LineEdit
@onready var email_validation_register_text: RichTextLabel = $Register_VBoxContainer/EmailGroup_VBoxContainer/EmailValidationText_RichTextLabel
@onready var password_register_line_edit: LineEdit = $Register_VBoxContainer/PasswordGroup_VBoxContainer/Password_LineEdit
@onready var password_validation_register_text: RichTextLabel = $Register_VBoxContainer/PasswordGroup_VBoxContainer/PasswordValidationText_RichTextLabel
@onready var dialog_background_color_rect: ColorRect = $DialogBackground_ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect signals
	NetworkManager.connection_failed.connect(_connection_to_server_failed)
	NetworkManager.connected_to_server.connect(_connection_to_server_successful)
	try_again_button.pressed.connect(_retry_server_connection)
	forgot_your_password_text_button.meta_clicked.connect(_change_to_forgot_your_password_panel)
	login_button.pressed.connect(_request_login)
	password_login_line_edit.text_submitted.connect(_request_login)
	email_login_line_edit.text_submitted.connect(_request_login)
	reset_password_button.pressed.connect(_request_password_reset)
	return_from_forgot_your_password_button.pressed.connect(_return_to_login_panel)
	register_now_login_text_button.meta_clicked.connect(_change_to_register_panel)
	return_from_register_button.pressed.connect(_return_to_login_panel)
	register_button.pressed.connect(_request_register_new_user)
	# Config initial visibility of panels
	connection_failed_container.hide()
	login_container.hide()
	forgot_your_password_container.hide()
	register_container.hide()
	trying_to_connect_container.show()
	# Config dialogs
	accept_dialog.transparent = true
	confirm_dialog.transparent = true
	accept_dialog.set_theme(login_menu_theme)
	confirm_dialog.set_theme(login_menu_theme)
	add_child(accept_dialog)
	add_child(confirm_dialog)
	accept_dialog.confirmed.connect(_hide_dialog_background)
	accept_dialog.canceled.connect(_hide_dialog_background)
	if multiplayer.has_multiplayer_peer():
		_connection_to_server_successful()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _show_accept_dialog(title: String, message: String, ok_text: String = "Ok"):
	accept_dialog.title = title
	accept_dialog.dialog_text = message
	accept_dialog.ok_button_text = ok_text
	dialog_background_color_rect.show()
	accept_dialog.popup_centered()


func _hide_dialog_background():
	dialog_background_color_rect.hide()


# Notify server connection issues and allow connection retry
func _connection_to_server_failed():
	trying_to_connect_container.hide()
	connection_failed_container.show()


# Retry server connection. Hide error nitification and disconnect pressed signal
func _retry_server_connection():
	connection_failed_container.hide()
	NetworkManager.create_client()
	trying_to_connect_container.show()


# Look for previous login and connect or show login
func _connection_to_server_successful():
	trying_to_connect_container.hide()
	# Show Log In menu
	login_container.show()


# Change to Forgot Your Password panel from Log In panel
@warning_ignore("unused_parameter")
func _change_to_forgot_your_password_panel(meta):
	login_container.hide()
	forgot_your_password_container.show()
	email_login_line_edit.clear()
	password_login_line_edit.clear()


# Send password reset request
func _request_password_reset():
	var email = email_forgot_your_password_line_edit.text.strip_edges()
	var error = false
	# Validate Email
	if email.is_empty() || RegEx.create_from_string("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$").search(email) == null:
		# Add info to validation field
		error = true
	# Check if there are errors
	if !error:
		# Send request
		AuthManager.server_reset_password.rpc_id(1, email)
		_set_forgot_password_inputs_interaction_status(false)
		var result = await wait_for_signal_response(AuthManager.reset_password_end, 10.0)
		if result.success:
			_show_accept_dialog("Success", result.message)
			_return_to_login_panel()
			email_forgot_your_password_line_edit.clear()
		else:
			_show_accept_dialog("Error", result.message)
		_set_forgot_password_inputs_interaction_status(true)
	else:
		_show_accept_dialog("Error", "Please, fill the gaps with correct info.", "Sorry, I will do it again...")


# Return to login panel from forgot your password panel
func _return_to_login_panel():
	forgot_your_password_container.hide()
	register_container.hide()
	login_container.show()
	# Clear Forgot Your Password fields
	email_forgot_your_password_line_edit.clear()
	# Clear Register fields
	nickname_register_line_edit.clear()
	email_register_line_edit.clear()
	password_register_line_edit.clear()
	nickname_validation_register_text.clear()
	email_validation_register_text.clear()
	password_validation_register_text.clear()


# Change to Register panel from Log In panel
@warning_ignore("unused_parameter")
func _change_to_register_panel(meta):
	if login_button.disabled:
		return
	login_container.hide()
	register_container.show()
	email_login_line_edit.clear()
	password_login_line_edit.clear()


# Send register new user request
func _request_register_new_user():
	# Validate inputs
	var nickname = nickname_register_line_edit.text.strip_edges()
	var email = email_register_line_edit.text.strip_edges()
	var password = password_register_line_edit.text
	var error = false
	# Validate Nickname
	if nickname.is_empty() || RegEx.create_from_string("^[a-zA-Z0-9_ ]{1,16}$").search(nickname) == null:
		# Add info to validation field
		error = true
		nickname_validation_register_text.text = 'Allowed characters: (a-z) (A-Z) _ space'
	else:
		nickname_validation_register_text.clear()
	# Validate Email
	if email.is_empty() || RegEx.create_from_string("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$").search(email) == null:
		# Add info to validation field
		error = true
		email_validation_register_text.text = 'Enter a valid email address'
	else:
		email_validation_register_text.clear()
	# Validate Password
	if password.length() < 8 || password.length() > 32:
		# Add info to validation field
		error = true
		password_validation_register_text.text = 'Length must be between 8 and 32 characters'
	else:
		email_validation_register_text.clear()
	# Check if there are errors
	if !error:
		# Send request
		AuthManager.server_register_user.rpc_id(1, nickname, email, password.sha256_text())
		_set_register_inputs_interaction_status(false)
		var result = await wait_for_signal_response(AuthManager.register_user_end, 10.0)
		if result.success:
			email_login_line_edit.text = email
			_return_to_login_panel()
		else:
			_show_accept_dialog("Error", result.message)
		_set_register_inputs_interaction_status(true)
	else:
		_show_accept_dialog("Error", "Please, fill the gaps with correct info.", "Sorry, I will do it again...")


func _set_register_inputs_interaction_status(status: bool):
	nickname_register_line_edit.editable = status
	email_register_line_edit.editable = status
	password_register_line_edit.editable = status
	register_button.disabled = !status
	return_from_register_button.disabled = !status


func _set_login_inputs_interaction_status(status: bool):
	email_login_line_edit.editable = status
	password_login_line_edit.editable = status
	login_button.disabled = !status


func _set_forgot_password_inputs_interaction_status(status: bool):
	email_forgot_your_password_line_edit.editable = status
	reset_password_button.disabled = !status
	return_from_forgot_your_password_button.disabled = !status


# Send login request to server
@warning_ignore("unused_parameter")
func _request_login(new_text: String = ""):
	var email = email_login_line_edit.text
	var password = password_login_line_edit.text
	# Send request
	AuthManager.server_login_user.rpc_id(1, email,password.sha256_text())
	_set_login_inputs_interaction_status(false)
	var result = await wait_for_signal_response(AuthManager.login_user_end, 10.0)
	if result.success:
		email_login_line_edit.clear()
		password_login_line_edit.clear()
		_store_user_data(JSON.parse_string(result.message))
		_change_to_logged_in_menu()
	else:
		_show_accept_dialog("Error", result.message)
	_set_login_inputs_interaction_status(true)


# Store in global client dict the user info
func _store_user_data(user_info: Dictionary):
	ClientGlobalData.storeUserInfo(user_info)


# Wait until signal response is received or the timeout is reached
func wait_for_signal_response(desired_signal: Signal, timeout: float) -> Dictionary:
	var timer = get_tree().create_timer(timeout)
	var state = {
		"response_received": false,
		"result": {},
	}
	# Temporarily connect the signal
	var on_response = func(success: bool, message: String):
		state.response_received = true
		state.result = {
			"success": success,
			"message": message
		}
	desired_signal.connect(on_response)
	# Wait response or timeout
	while not state.response_received and timer.time_left > 0:
		await get_tree().process_frame
	# Disconnect signal
	desired_signal.disconnect(on_response)
	# Check if response has been received or not
	if not state.response_received:
		return {
			"success": false,
			"message": "❌ Timeout: Server is not responding"
		}
	return state.result


# Change scene to 
func _change_to_logged_in_menu():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
