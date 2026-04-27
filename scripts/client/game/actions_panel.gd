extends PanelContainer
class_name ActionsPanel


@onready var avatar_control: ActionsPanelAvatar = $MarginContainer/VBoxContainer/HSplitContainer/Avatar_Control
@onready var character_info_rich_text_label: RichTextLabel = $MarginContainer/VBoxContainer/HSplitContainer/CharacterInfo_RichTextLabel


func set_up_panel(character: Enums.Character) -> void:
	avatar_control.set_character(character)
	character_info_rich_text_label.text = str(Enums.CHARACTER_INFO[character]["name"], "\n",
											  Enums.CHARACTER_INFO[character]["animal"], "\n",
											  Enums.CHARACTER_INFO[character]["profession"])
