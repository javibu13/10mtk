extends VBoxContainer

@onready var quick_match_button: Button = $PlayButtons_VBoxContainer/QuickMatch_Button
@onready var create_match_button: Button = $PlayButtons_VBoxContainer/CreateMatch_Button
@onready var join_match_button: Button = $PlayButtons_VBoxContainer/JoinMatch_Button
@onready var quick_match_menu_v_box_container: VBoxContainer = $"../QuickMatchMenu_VBoxContainer"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	quick_match_button.pressed.connect(_change_to_quick_match_menu)


func _change_to_quick_match_menu() -> void:
	self.hide()
	quick_match_menu_v_box_container.initialize()
	quick_match_menu_v_box_container.show()
