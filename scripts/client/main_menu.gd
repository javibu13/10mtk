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
@onready var credits_texture_button: TextureButton = $Credits_TextureButton
@onready var credits_menu: Control = $CreditsMenu
@onready var avatar_control: ActionsPanelAvatar = $UserInfo_HBoxContainer/Avatar_Control
@onready var character_left_background_texture_rect: TextureRect = $CharacterLeftBackground_TextureRect
@onready var character_right_background_texture_rect: TextureRect = $CharacterRightBackground_TextureRect


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
	credits_texture_button.pressed.connect(func(): credits_menu.show())
	credits_menu.hide()
	_set_up_background_characters(ClientGlobalData.character_left, ClientGlobalData.character_right)
	var random_character = Enums.Character.values().pick_random()
	avatar_control.set_character(random_character if random_character != 0 else Enums.Character.TIGER)


# Execute function to ask the server to end user's session and change to login view
func _logout() -> void:
	AuthManager.server_log_out.rpc_id(1)
	get_tree().change_scene_to_file("res://scenes/LoginMenu.tscn")


func _set_up_background_characters(stored_character_left: int, stored_character_right: int) -> void:
	var available_characters_array = Enums.Character.values()
	available_characters_array.erase(0)
	var character_left = available_characters_array.pick_random()
	available_characters_array.erase(character_left)
	var character_right = available_characters_array.pick_random()
	if stored_character_left != 0 and stored_character_right != 0:
		character_left = stored_character_left
		character_right = stored_character_right
	var character_left_info = Enums.CHARACTER_INFO[character_left]
	var character_right_info = Enums.CHARACTER_INFO[character_right]
	character_left_background_texture_rect.texture = load(character_left_info.image_path)
	character_left_background_texture_rect.flip_h = character_left_info.facing_direction == "left"
	character_right_background_texture_rect.texture = load(character_right_info.image_path)
	character_right_background_texture_rect.flip_h = character_right_info.facing_direction == "right"
