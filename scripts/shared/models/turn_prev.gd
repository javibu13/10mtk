class_name TurnPrev
extends Turn


var action: Enums.Action = Enums.Action.MOVE
var character: Enums.Character = Enums.Character.NONE
var asked_player_index: int = -1


func _init(turn: Turn, new_action: Enums.Action, new_character: Enums.Character, new_asked_player_index: int = -1) -> void:
	super._init(turn.player_index, turn.action_number, turn.time)
	action = new_action
	character = new_character
	asked_player_index = new_asked_player_index


func to_dict() -> Dictionary:
	return {
		"player_index": player_index,
		"action_number": action_number,
		"time": time,
		"action": action,
		"character": character,
		"asked_player_index": asked_player_index,
	}
