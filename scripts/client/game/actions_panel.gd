extends PanelContainer
class_name ActionsPanel


@onready var avatar_control: ActionsPanelAvatar = $MarginContainer/VBoxContainer/HSplitContainer/Avatar_Control
@onready var character_info_rich_text_label: RichTextLabel = $MarginContainer/VBoxContainer/HSplitContainer/CharacterInfo_RichTextLabel
@onready var move_action_button: Button = $MarginContainer/VBoxContainer/MoveAction_Button
@onready var kill_action_button: Button = $MarginContainer/VBoxContainer/KillAction_Button
@onready var investigate_action_button: Button = $MarginContainer/VBoxContainer/InvestigateAction_Button
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("hidden")


func set_up_panel(character: Enums.Character, allow_move_action := true, allow_kill_action := false, allow_investigate_action := false) -> void:
	avatar_control.set_character(character)
	character_info_rich_text_label.text = str(Enums.CHARACTER_INFO[character]["name"], "\n",
											  Enums.CHARACTER_INFO[character]["animal"], "\n",
											  Enums.CHARACTER_INFO[character]["profession"])
	move_action_button.disabled = not allow_move_action
	kill_action_button.disabled = not allow_kill_action
	investigate_action_button.disabled = not allow_investigate_action
	animation_player.play("show_panel")
