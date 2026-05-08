extends VBoxContainer

@onready var quick_match_button: Button = $PlayButtons_VBoxContainer/QuickMatch_Button
@onready var create_match_button: Button = $PlayButtons_VBoxContainer/CreateMatch_Button
@onready var join_match_button: Button = $PlayButtons_VBoxContainer/JoinMatch_Button
@onready var quick_match_menu_v_box_container: VBoxContainer = $"../QuickMatchMenu_VBoxContainer"
@onready var log_out_button: TextureButton = $"../LogOut_TextureButton"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	quick_match_button.pressed.connect(_change_to_quick_match_menu)


func _change_to_quick_match_menu() -> void:
	SoundManager.instance_and_play_sound(quick_match_button, SoundManager.button_mouse_pressed_sfx_resource)
	self.hide()
	log_out_button.hide()
	quick_match_button.disabled = true
	quick_match_menu_v_box_container.initialize()
	quick_match_menu_v_box_container.show()
