class_name Turn
extends RefCounted

var player_index: int
var action_number: Enums.ActionNumber = Enums.ActionNumber.FIRST
var time: int
var previous: TurnPrev


static func server_new(new_player_index: int, new_action_number: Enums.ActionNumber, new_time: int, new_previos_turn: TurnPrev = null) -> Turn:
	var new_turn: Turn = Turn.new()
	new_turn.player_index = new_player_index
	new_turn.action_number = new_action_number
	new_turn.time = new_time
	new_turn.previous = new_previos_turn
	return new_turn


func to_dict() -> Dictionary:
	return {
		"player_index": player_index,
		"action_number": action_number,
		"time": time,
		"previous": previous.to_dict() if previous != null else {},
	}


# Create object using dictionary and basic data type structure
static func from_dict(new_dict: Dictionary) -> Turn:
	var new_turn: Turn = Turn.new()
	new_turn.player_index = new_dict.player_index
	new_turn.action_number = new_dict.action_number
	new_turn.time = new_dict.time
	new_turn.previous = TurnPrev.from_dict(new_dict.previous) if not new_dict.previous.is_empty() else null
	return new_turn
