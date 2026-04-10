extends Control

@onready var user_name_text: RichTextLabel = $UserInfo_HBoxContainer/UserName_RichTextLabel
@onready var logout_button: TextureButton = $LogOut_TextureButton
@onready var main_menu_container: Container =  $MainMenuButtons_VBoxContainer
@onready var quick_match_menu_v_box_container: VBoxContainer = $QuickMatchMenu_VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	user_name_text.text = ClientGlobalData.user_info.nickname
	logout_button.pressed.connect(_logout)
	main_menu_container.show()
	quick_match_menu_v_box_container.hide()


# Execute function to ask the server to end user's session and change to login view
func _logout() -> void:
	AuthManager.server_log_out.rpc_id(1)
	get_tree().change_scene_to_file("res://scenes/LoginMenu.tscn")
