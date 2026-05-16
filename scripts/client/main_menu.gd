extends Control

@onready var user_name_text: RichTextLabel = $UserInfo_HBoxContainer/UserName_RichTextLabel
@onready var log_out_button: TextureButton = $LogOut_TextureButton
@onready var main_menu_container: Container =  $MainMenuButtons_VBoxContainer
@onready var quick_match_menu_v_box_container: VBoxContainer = $QuickMatchMenu_VBoxContainer
@onready var dialog_background_color_rect: ColorRect = $DialogBackground_ColorRect
@onready var countdown_quick_match_v_box_container: VBoxContainer = $CountdownQuickMatch_VBoxContainer
@onready var settings_texture_button: TextureButton = $Settings_TextureButton
@onready var settings_menu: SettingsMenu = $SettingsMenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	user_name_text.text = ClientGlobalData.user_info.nickname
	log_out_button.pressed.connect(_logout)
	main_menu_container.show()
	quick_match_menu_v_box_container.hide()
	dialog_background_color_rect.hide()
	countdown_quick_match_v_box_container.hide()
	SoundManager.play_main_menu_music()
	SoundManager.resync_control_sounds()
	settings_texture_button.pressed.connect(func(): settings_menu.show())
	settings_menu.hide()


# Execute function to ask the server to end user's session and change to login view
func _logout() -> void:
	AuthManager.server_log_out.rpc_id(1)
	get_tree().change_scene_to_file("res://scenes/LoginMenu.tscn")
