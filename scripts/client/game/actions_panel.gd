extends PanelContainer
class_name ActionsPanel

@export var game_root: GameRootNode

var x_close_scale_normal: Vector2 = Vector2(15, 15)
var x_close_scale_hover: Vector2 = Vector2(18, 18)

@onready var avatar_control: ActionsPanelAvatar = $Main_MarginContainer/VBoxContainer/HSplitContainer/Avatar_Control
@onready var character_info_rich_text_label: RichTextLabel = $Main_MarginContainer/VBoxContainer/HSplitContainer/CharacterInfo_RichTextLabel
@onready var move_action_button: Button = $Main_MarginContainer/VBoxContainer/MoveAction_Button
@onready var kill_action_button: Button = $Main_MarginContainer/VBoxContainer/KillAction_Button
@onready var investigate_action_button: Button = $Main_MarginContainer/VBoxContainer/InvestigateAction_Button
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var texture_button: TextureButton = $X_MarginContainer/TextureButton


func _ready() -> void:
	animation_player.play("hidden")
	texture_button.mouse_entered.connect(x_close_mouse_enter)
	texture_button.mouse_exited.connect(x_close_mouse_exit)
	texture_button.pressed.connect(x_close_pressed)


func set_up_panel(character: Enums.Character, allow_move_action := true, allow_kill_action := false, allow_investigate_action := false) -> void:
	avatar_control.set_character(character)
	character_info_rich_text_label.text = str(Enums.CHARACTER_INFO[character]["name"], "\n",
											  Enums.CHARACTER_INFO[character]["animal"], "\n",
											  Enums.CHARACTER_INFO[character]["profession"])
	move_action_button.disabled = not allow_move_action
	kill_action_button.disabled = not allow_kill_action
	investigate_action_button.disabled = not allow_investigate_action
	animation_player.play("show_panel")


func x_close_mouse_enter() -> void:
	texture_button.custom_minimum_size = x_close_scale_hover


func x_close_mouse_exit() -> void:
	texture_button.custom_minimum_size = x_close_scale_normal


func x_close_pressed() -> void:
	game_root.actions_panel_closed.emit()
	animation_player.play("hide_panel")
