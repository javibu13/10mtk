extends VBoxContainer

var waiting_for_players_text = "Waiting for players"
var waiting_effect_text = ""

@onready var waiting_effect_timer: Timer = $WaitingEffect_Timer
@onready var info_text_label: RichTextLabel = $QuickMatchInfo_VBoxContainer/Info_RichTextLabel
@onready var return_button: Button = $QuickMatchInfo_VBoxContainer/Return_Button
@onready var main_menu_buttons_v_box_container: VBoxContainer = $"../MainMenuButtons_VBoxContainer"
@onready var log_out_button: TextureButton = $"../LogOut_TextureButton"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	waiting_effect_timer.timeout.connect(_update_waiting_effect)
	return_button.pressed.connect(_change_to_main_menu_buttons)


func initialize() -> void:
	info_text_label.text = waiting_for_players_text
	info_text_label.show()
	waiting_effect_timer.start()
	MatchmakingManager.server_join_client_to_quick_lobby.rpc_id(1)


func _update_waiting_effect() -> void:
	waiting_effect_text += "."
	if waiting_effect_text.length() > 3:
		waiting_effect_text = ""
	var lobby_size_status_formatted = ""
	if ClientGlobalData.lobby_size_status:
		lobby_size_status_formatted = "\n (" + ClientGlobalData.lobby_size_status + ") "
	info_text_label.text = waiting_for_players_text + waiting_effect_text + lobby_size_status_formatted


func _change_to_main_menu_buttons() -> void:
	waiting_effect_timer.stop()
	self.hide()
	log_out_button.show()
	main_menu_buttons_v_box_container.show()
	# Inform that lobby is leaved and reset data stored about lobby
	MatchmakingManager.server_client_leaves_lobby.rpc_id(1)
	ClientGlobalData.resetLobbyData()
