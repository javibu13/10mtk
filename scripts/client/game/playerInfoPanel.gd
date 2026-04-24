extends PanelContainer
class_name PlayerInfoPanel

var player_index: int = -1

@export var type: Enums.PlayerInfoPanelType
@export var player_info_assassin: PlayerInfoCharacter
@export var player_info_objectives: Array[PlayerInfoCharacter]
@export var user_name_text: RichTextLabel


func _ready() -> void:
	# Start hidden because it will be shown if it is needed depending on number of players
	self.hide()


func set_user_name(new_user_name: String) -> void:
	if user_name_text:
		user_name_text.text = new_user_name
