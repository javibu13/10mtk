class_name Turn
extends RefCounted

var player_index: int
var action_number: Enums.ActionNumber = Enums.ActionNumber.FIRST
var time: int
var previous: TurnPrev


func _init(new_player_index: int, new_action_number: Enums.ActionNumber, new_time: int, new_previos_turn: TurnPrev = null) -> void:
	player_index = new_player_index
	action_number = new_action_number
	time = new_time
	previous = new_previos_turn


func to_dict() -> Dictionary:
	return {
		"player_index": player_index,
		"action_number": action_number,
		"time": time,
		"previous": previous.to_dict() if previous != null else {},
	}
