extends Control

@onready var user_name_text: RichTextLabel = $UserInfo_HBoxContainer/UserName_RichTextLabel
@onready var log_out_button: TextureButton = $LogOut_TextureButton
@onready var main_menu_container: Container =  $MainMenuButtons_VBoxContainer
@onready var quick_match_menu_v_box_container: VBoxContainer = $QuickMatchMenu_VBoxContainer
@onready var dialog_background_color_rect: ColorRect = $DialogBackground_ColorRect
@onready var countdown_quick_match_v_box_container: VBoxContainer = $CountdownQuickMatch_VBoxContainer
@onready var settings_texture_button: TextureButton = $Settings_TextureButton
@onready var settings_menu: SettingsMenu = $SettingsMenu
@onready var how_to_play_texture_button: TextureButton = $HowToPlay_TextureButton
@onready var how_to_play_menu: Control = $HowToPlayMenu
@onready var avatar_control: ActionsPanelAvatar = $UserInfo_HBoxContainer/Avatar_Control


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
	how_to_play_texture_button.pressed.connect(func(): how_to_play_menu.show())
	how_to_play_menu.hide()
	var random_character = Enums.Character.values().pick_random()
	avatar_control.set_character(random_character if random_character != 0 else Enums.Character.TIGER)


# Execute function to ask the server to end user's session and change to login view
func _logout() -> void:
	AuthManager.server_log_out.rpc_id(1)
	get_tree().change_scene_to_file("res://scenes/LoginMenu.tscn")
