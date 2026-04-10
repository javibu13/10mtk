extends Control

@onready var user_name_text: RichTextLabel = $UserInfo_HBoxContainer/UserName_RichTextLabel
@onready var logout_button: TextureButton = $LogOut_TextureButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	user_name_text.text = ClientGlobalData.user_info.nickname
	logout_button.pressed.connect(_logout)


# Execute function to ask the server to end user's session and change to login view
func _logout() -> void:
	AuthManager.server_log_out.rpc_id(1)
	get_tree().change_scene_to_file("res://scenes/LoginMenu.tscn")
