extends VBoxContainer

var waiting_for_players_text = "Waiting for players"
var waiting_effect_text = ""

@onready var waiting_effect_timer: Timer = $WaitingEffect_Timer
@onready var info_text_label: RichTextLabel = $QuickMatchInfo_VBoxContainer/Info_RichTextLabel
@onready var return_button: Button = $QuickMatchInfo_VBoxContainer/Return_Button
@onready var main_menu_buttons_v_box_container: VBoxContainer = $"../MainMenuButtons_VBoxContainer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	waiting_effect_timer.timeout.connect(_update_waiting_effect)
	return_button.pressed.connect(_change_to_main_menu_buttons)


func initialize() -> void:
	info_text_label.text = waiting_for_players_text
	info_text_label.show()
	waiting_effect_timer.start()


func _update_waiting_effect() -> void:
	waiting_effect_text += "."
	if waiting_effect_text.length() > 3:
		waiting_effect_text = ""
	info_text_label.text = waiting_for_players_text + waiting_effect_text


func _change_to_main_menu_buttons() -> void:
	waiting_effect_timer.stop()
	self.hide()
	main_menu_buttons_v_box_container.show()
