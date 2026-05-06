extends PanelContainer
class_name ActionsPanel

@export var game_root: GameRootNode

var x_close_scale_normal: Vector2 = Vector2(15, 15)
var x_close_scale_hover: Vector2 = Vector2(18, 18)
var is_action_editing_in_progress := false
var _last_anim_played_action_container := ""

@onready var avatar_control: ActionsPanelAvatar = $Main_MarginContainer/VBoxContainer/HSplitContainer/Avatar_Control
@onready var character_info_rich_text_label: RichTextLabel = $Main_MarginContainer/VBoxContainer/HSplitContainer/CharacterInfo_RichTextLabel
@onready var move_action_button: Button = $Main_MarginContainer/VBoxContainer/ButtonsArea_Control/Actions_VBoxContainer/MoveAction_Button
@onready var kill_action_button: Button = $Main_MarginContainer/VBoxContainer/ButtonsArea_Control/Actions_VBoxContainer/KillAction_Button
@onready var investigate_action_button: Button = $Main_MarginContainer/VBoxContainer/ButtonsArea_Control/Actions_VBoxContainer/InvestigateAction_Button
@onready var actions_panel_animation_player: AnimationPlayer = $AnimationPlayer
@onready var x_texture_button: TextureButton = $X_MarginContainer/X_TextureButton
@onready var buttons_area_animation_player: AnimationPlayer = $Main_MarginContainer/VBoxContainer/ButtonsArea_Control/AnimationPlayer
@onready var action_info_rich_text_label: RichTextLabel = $Main_MarginContainer/VBoxContainer/ButtonsArea_Control/ActionConfirmation_VBoxContainer2/ActionInfo_RichTextLabel
@onready var players_to_investigate_option_button: OptionButton = $Main_MarginContainer/VBoxContainer/ButtonsArea_Control/ActionConfirmation_VBoxContainer2/PlayersToInvestigate_OptionButton
@onready var cancel_texture_button: TextureButton = $Main_MarginContainer/VBoxContainer/ButtonsArea_Control/ActionConfirmation_VBoxContainer2/ConfirmCancel_HBoxContainer/Cancel_TextureButton
@onready var confirm_texture_button: TextureButton = $Main_MarginContainer/VBoxContainer/ButtonsArea_Control/ActionConfirmation_VBoxContainer2/ConfirmCancel_HBoxContainer/Confirm_TextureButton


func _ready() -> void:
	actions_panel_animation_player.play("hidden")
	_last_anim_played_action_container = "hidden"
	buttons_area_animation_player.play("RESET")
	x_texture_button.mouse_entered.connect(x_close_mouse_enter)
	x_texture_button.mouse_exited.connect(x_close_mouse_exit)
	x_texture_button.pressed.connect(x_close_pressed)
	move_action_button.pressed.connect(move_action_pressed)
	kill_action_button.pressed.connect(kill_action_pressed)
	investigate_action_button.pressed.connect(investigate_action_pressed)
	cancel_texture_button.pressed.connect(cancel_action_editing)


func set_up_panel(character: Enums.Character, allow_move_action := true, allow_kill_action := false, allow_investigate_action := false) -> void:
	avatar_control.set_character(character)
	character_info_rich_text_label.text = str(Enums.CHARACTER_INFO[character]["name"], "\n",
											  Enums.CHARACTER_INFO[character]["animal"], "\n",
											  Enums.CHARACTER_INFO[character]["profession"])
	# Move Button
	move_action_button.disabled = not allow_move_action
	move_action_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if allow_move_action else Control.CURSOR_ARROW
	# Kill Button
	kill_action_button.disabled = not allow_kill_action
	kill_action_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if allow_kill_action else Control.CURSOR_ARROW
	# Investigate Button
	investigate_action_button.disabled = not allow_investigate_action
	investigate_action_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if allow_investigate_action else Control.CURSOR_ARROW
	
	is_action_editing_in_progress = false
	buttons_area_animation_player.play("RESET")
	actions_panel_animation_player.play("show_panel")
	_last_anim_played_action_container = "show_panel"
	confirm_texture_button.disabled = false


func x_close_mouse_enter() -> void:
	x_texture_button.custom_minimum_size = x_close_scale_hover


func x_close_mouse_exit() -> void:
	x_texture_button.custom_minimum_size = x_close_scale_normal


func x_close_pressed() -> void:
	game_root.actions_panel_closed.emit()
	actions_panel_animation_player.play("hide_panel")
	_last_anim_played_action_container = "hide_panel"
	if is_action_editing_in_progress:
		is_action_editing_in_progress = false
		game_root.action_editing_canceled.emit()


## Executes x_close_pressed() only if the panel was not hidden
func safe_x_close_pressed() -> void:
	if _last_anim_played_action_container != "hide_panel":
		x_close_pressed()


func close_after_confirm_action() -> void:
	game_root.actions_panel_closed.emit()
	actions_panel_animation_player.play("hide_panel")
	_last_anim_played_action_container = "hide_panel"
	is_action_editing_in_progress = false
	game_root.action_editing_finished.emit()


func move_action_pressed() -> void:
	is_action_editing_in_progress = true
	restart_action_details_panel()
	game_root.action_editing_started.emit(Enums.Action.MOVE)
	action_info_rich_text_label.text = "Select the tile you want to move the character to and confirm"
	confirm_texture_button.pressed.connect(move_action_confirmed)
	buttons_area_animation_player.play("actions_to_action_details")


func kill_action_pressed() -> void:
	is_action_editing_in_progress = true
	restart_action_details_panel()
	game_root.action_editing_started.emit(Enums.Action.KILL)
	action_info_rich_text_label.text = "Are you sure you want to kill this character?"
	confirm_texture_button.pressed.connect(kill_action_confirmed)
	buttons_area_animation_player.play("actions_to_action_details")


func investigate_action_pressed() -> void:
	is_action_editing_in_progress = true
	restart_action_details_panel()
	game_root.action_editing_started.emit(Enums.Action.ASK)
	var unknown_players: Array[Player] = ClientGlobalData.public_game.players.filter(func(player: Player): return player.assassin <= 0)
	players_to_investigate_option_button.clear()
	for player in unknown_players:
		players_to_investigate_option_button.add_item(player.user_name, player.index)
	players_to_investigate_option_button.show()
	action_info_rich_text_label.text = "Select the player to investigate if they are the character"
	confirm_texture_button.pressed.connect(investigate_action_confirmed)
	buttons_area_animation_player.play("actions_to_action_details")


func restart_action_details_panel() -> void:
	var confirm_button_connections = confirm_texture_button.pressed.get_connections()
	for confirm_button_connection in confirm_button_connections:
		confirm_button_connection.signal.disconnect(confirm_button_connection.callable)
	confirm_texture_button.disabled = false
	players_to_investigate_option_button.hide()


func cancel_action_editing() -> void:
	is_action_editing_in_progress = false
	game_root.action_editing_canceled.emit()
	buttons_area_animation_player.play("action_details_to_actions")


func move_action_confirmed() -> void:
	is_action_editing_in_progress = false
	game_root.action_confirmed.emit({
		"type": Enums.Action.MOVE
	})
	confirm_texture_button.disabled = true
	close_after_confirm_action.call_deferred()


func kill_action_confirmed() -> void:
	is_action_editing_in_progress = false
	game_root.action_confirmed.emit({
		"type": Enums.Action.KILL
	})
	confirm_texture_button.disabled = true
	close_after_confirm_action.call_deferred()


func investigate_action_confirmed() -> void:
	if players_to_investigate_option_button.get_selected_id() < 0:
		# OptionButton hasn't got any player selected
		players_to_investigate_option_button.show_popup()
		return
	is_action_editing_in_progress = false
	game_root.action_confirmed.emit({
		"type": Enums.Action.ASK, 
		"player_index_option": players_to_investigate_option_button.get_selected_id()
	})
	confirm_texture_button.disabled = true
	close_after_confirm_action.call_deferred()
