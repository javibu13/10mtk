extends VBoxContainer

const QUICK_MATCH_OPTIONS = ["Quick Match", "Quick 2 Players", "Quick 3 Players", "Quick 4 Players"]

@onready var quick_match_button: Button = $PlayButtons_VBoxContainer/HBoxContainer/QuickMatch_Button
@onready var create_match_button: Button = $PlayButtons_VBoxContainer/CreateMatch_Button
@onready var join_match_button: Button = $PlayButtons_VBoxContainer/JoinMatch_Button
@onready var quick_match_menu_v_box_container: VBoxContainer = $"../QuickMatchMenu_VBoxContainer"
@onready var log_out_button: TextureButton = $"../LogOut_TextureButton"
@onready var quick_match_left_arrow_texture_button: TextureButton = $PlayButtons_VBoxContainer/HBoxContainer/QuickMatchLeftArrowTextureButton
@onready var quick_match_right_arrow_texture_button: TextureButton = $PlayButtons_VBoxContainer/HBoxContainer/QuickMatchRightArrowTextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	quick_match_button.pressed.connect(_change_to_quick_match_menu)
	quick_match_left_arrow_texture_button.pressed.connect(_change_quick_match_display_text.bind(-1))
	quick_match_right_arrow_texture_button.pressed.connect(_change_quick_match_display_text.bind(+1))


func _change_to_quick_match_menu() -> void:
	SoundManager.instance_and_play_sound(quick_match_button, SoundManager.button_mouse_pressed_sfx_resource)
	self.hide()
	log_out_button.hide()
	quick_match_button.disabled = true
	quick_match_menu_v_box_container.initialize(_get_current_quick_match_type())
	quick_match_menu_v_box_container.show()


func _change_quick_match_display_text(index_increment: int = 0) -> void:
	var new_quick_match_option_index: int = QUICK_MATCH_OPTIONS.find(quick_match_button.text) + index_increment
	if new_quick_match_option_index >= QUICK_MATCH_OPTIONS.size():
		new_quick_match_option_index = 0
	elif new_quick_match_option_index < 0:
		new_quick_match_option_index = QUICK_MATCH_OPTIONS.size() - 1
	quick_match_button.text = QUICK_MATCH_OPTIONS[new_quick_match_option_index]


func _get_current_quick_match_type() -> Enums.QuickLobbyType:
	return QUICK_MATCH_OPTIONS.find(quick_match_button.text) as Enums.QuickLobbyType
