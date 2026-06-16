extends VBoxContainer

var waiting_for_players_text = "Waiting for players"
var waiting_effect_text = ""
var countdown_time_left := 0
var countdown_time := 0
var manual_rejected := false

@onready var waiting_effect_timer: Timer = $WaitingEffect_Timer
@onready var info_text_label: RichTextLabel = $QuickMatchInfo_VBoxContainer/Info_RichTextLabel
@onready var return_button: Button = $QuickMatchInfo_VBoxContainer/Return_Button
@onready var main_menu_buttons_v_box_container: VBoxContainer = $"../MainMenuButtons_VBoxContainer"
@onready var quick_match_button: Button = $"../MainMenuButtons_VBoxContainer/PlayButtons_VBoxContainer/HBoxContainer/QuickMatch_Button"
@onready var log_out_button: TextureButton = $"../LogOut_TextureButton"
@onready var animation_player: AnimationPlayer = $"../CountdownQuickMatch_VBoxContainer/CountdownCounter_Container/Aim_TextureRect/AnimationPlayer"
@onready var aim_texture_rect: TextureRect = $"../CountdownQuickMatch_VBoxContainer/CountdownCounter_Container/Aim_TextureRect"
@onready var countdown_quick_match_v_box_container: VBoxContainer = $"../CountdownQuickMatch_VBoxContainer"
@onready var countdown_timer: Timer = $"../CountdownQuickMatch_VBoxContainer/Countdown_Timer"
@onready var dialog_background_color_rect: ColorRect = $"../DialogBackground_ColorRect"
@onready var counter_text: RichTextLabel = $"../CountdownQuickMatch_VBoxContainer/CountdownCounter_Container/Counter_RichTextLabel"
@onready var accept_button: Button = $"../CountdownQuickMatch_VBoxContainer/QuickMatchInfo_VBoxContainer/Accept_Button"
@onready var reject_button: Button = $"../CountdownQuickMatch_VBoxContainer/QuickMatchInfo_VBoxContainer/Reject_Button"
@onready var accepted_match_texture_rect: TextureRect = $"../CountdownQuickMatch_VBoxContainer/CountdownCounter_Container/AcceptedMatch_TextureRect"
@onready var rejected_match_texture_rect: TextureRect = $"../CountdownQuickMatch_VBoxContainer/CountdownCounter_Container/RejectedMatch_TextureRect"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	waiting_effect_timer.timeout.connect(_update_waiting_effect)
	return_button.pressed.connect(_change_to_main_menu_buttons)
	MatchmakingManager.request_accept_match_start.connect(_launch_match_accept_countdown)
	countdown_timer.timeout.connect(_countdown_timeout)
	accept_button.pressed.connect(_accept_game_start)
	reject_button.pressed.connect(_reject_game_start)
	MatchmakingManager.return_to_quick_mode_search.connect(_return_to_quick_mode_search)
	MatchmakingManager.kicked_from_quick_mode_search_to_main_menu.connect(_return_to_main_menu_buttons_kicked_from_quick_mode_search)
	MatchmakingManager.change_to_match.connect(_change_to_game_scene)


func initialize(quick_lobby_type: Enums.QuickLobbyType = Enums.QuickLobbyType.RANDOM) -> void:
	return_button.disabled = false
	info_text_label.text = waiting_for_players_text
	info_text_label.show()
	waiting_effect_timer.paused = false
	waiting_effect_timer.start()
	MatchmakingManager.server_join_client_to_quick_lobby.rpc_id(1, quick_lobby_type)


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
	quick_match_button.disabled = false
	main_menu_buttons_v_box_container.show()
	# Inform that lobby is leaved and reset data stored about lobby
	MatchmakingManager.server_client_leaves_lobby.rpc_id(1)
	ClientGlobalData.resetLobbyData()


func _launch_match_accept_countdown(new_countdown_time: int) -> void:
	SoundManager.instance_and_play_sound(null, SoundManager.match_found_sfx_resource)
	accepted_match_texture_rect.hide()
	rejected_match_texture_rect.hide()
	aim_texture_rect.modulate = Color.WHITE
	return_button.disabled = true
	waiting_effect_timer.paused = false
	animation_player.play("idle")
	countdown_time = new_countdown_time
	countdown_time_left = countdown_time
	counter_text.text = str("[b]", countdown_time_left, "[/b]")
	accept_button.disabled = false
	reject_button.disabled = false
	dialog_background_color_rect.show()
	countdown_quick_match_v_box_container.show()
	countdown_timer.start()


func _countdown_timeout() -> void:
	countdown_time_left -= 1
	if countdown_time_left < 0:
		countdown_timer.stop()
		MatchmakingManager.server_client_rejects_match.rpc_id(1)
	else:
		# Update counter text
		SoundManager.instance_and_play_sound(null, SoundManager.countdown_beep_sfx_resource, 5.0, 1.0)
		counter_text.text = str("[b]", countdown_time_left, "[/b]")


func _accept_game_start() -> void:
	countdown_timer.stop()
	SoundManager.instance_and_play_sound(null, SoundManager.shoot_accept_countdown_sfx_resource)
	SoundManager.instance_and_play_sound(null, SoundManager.wilhelm_countdown_sfx_resource, -5.0, randf_range(0.8, 1.2))
	MatchmakingManager.server_client_accepts_match.rpc_id(1)
	accepted_match_texture_rect.show()
	accept_button.disabled = true
	reject_button.disabled = true


func _reject_game_start() -> void:
	countdown_timer.stop()
	SoundManager.instance_and_play_sound(null, SoundManager.wrong_cancel_countdown_sfx_resource)
	MatchmakingManager.server_client_rejects_match.rpc_id(1)
	#aim_texture_rect.modulate = Color("#696969")
	rejected_match_texture_rect.show()
	accept_button.disabled = true
	reject_button.disabled = true
	manual_rejected = true


func _return_to_quick_mode_search() -> void:
	dialog_background_color_rect.hide()
	countdown_quick_match_v_box_container.hide()
	waiting_effect_timer.paused = false
	return_button.disabled = false


func _return_to_main_menu_buttons_kicked_from_quick_mode_search() -> void:
	if not manual_rejected:
		SoundManager.instance_and_play_sound(null, SoundManager.wrong_cancel_countdown_sfx_resource)
		manual_rejected = false
	dialog_background_color_rect.hide()
	countdown_quick_match_v_box_container.hide()
	waiting_effect_timer.stop()
	self.hide()
	quick_match_button.disabled = false
	log_out_button.show()
	main_menu_buttons_v_box_container.show()
	# Reset data stored about lobby
	ClientGlobalData.resetLobbyData()


func _change_to_game_scene(match_id: int) -> void:
	ClientGlobalData.match_id = match_id
	get_tree().change_scene_to_file("res://scenes/game/Game.tscn")
