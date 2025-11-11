extends Control

var server_timeout: float = 5.0

@onready var trying_to_connect_container: VBoxContainer = $TryingToConnect_VBoxContainer
@onready var connection_failed_container: VBoxContainer = $ConnectionFailed_VBoxContainer
@onready var login_container: VBoxContainer = $Login_VBoxContainer
@onready var forgot_your_password_container: VBoxContainer = $ForgotYourPassword_VBoxContainer
@onready var try_again_button: Button = $ConnectionFailed_VBoxContainer/TryAgain_Button
@onready var forgot_your_password_text_button: RichTextLabel = $Login_VBoxContainer/PasswordGroup_VBoxContainer/ForgotPassword_RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NetworkManager.connection_failed.connect(_connection_to_server_failed)
	NetworkManager.connected_to_server.connect(_connection_to_server_successful)
	try_again_button.pressed.connect(_retry_server_connection)
	forgot_your_password_text_button.meta_clicked.connect(_change_to_forgot_your_password_panel)
	connection_failed_container.hide()
	login_container.hide()
	trying_to_connect_container.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
	# TODO: Verify if there was a previous connection
	# Show Log In menu
	login_container.show()

# Change to Forgot Your Password panel from Log In panel
func _change_to_forgot_your_password_panel(meta):
	login_container.hide()
	forgot_your_password_container.show()
