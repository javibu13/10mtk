class_name TurnPrev
extends Turn


var action: Enums.Action = Enums.Action.MOVE
var character: Enums.Character = Enums.Character.NONE
var asked_player_index: int = -1
var tile: Vector2i = Vector2i.ZERO


static func server_new_prev(turn: Turn, new_action: Enums.Action, new_character: Enums.Character, new_asked_player_index: int = -1, new_tile: Vector2i = Vector2i.ZERO) -> TurnPrev:
	var new_turn_prev: TurnPrev = TurnPrev.new()
	var new_turn: Turn = Turn.server_new(turn.player_index, turn.action_number, turn.time)
	new_turn_prev.player_index = new_turn.player_index
	new_turn_prev.action_number = new_turn.action_number
	new_turn_prev.time = new_turn.time
	new_turn_prev.action = new_action
	new_turn_prev.character = new_character
	new_turn_prev.asked_player_index = new_asked_player_index
	new_turn_prev.tile = new_tile
	return new_turn_prev


func to_dict() -> Dictionary:
	return {
		"player_index": player_index,
		"action_number": action_number,
		"time": time,
		"action": action,
		"character": character,
		"asked_player_index": asked_player_index,
		"tile": [tile.x, tile.y],
	}


# Create object using dictionary and basic data type structure
static func from_dict(new_dict: Dictionary) -> TurnPrev:
	var new_turn_prev: TurnPrev = TurnPrev.new()
	new_turn_prev.player_index = new_dict.player_index
	new_turn_prev.action_number = new_dict.action_number
	new_turn_prev.time = new_dict.time
	new_turn_prev.action = new_dict.action
	new_turn_prev.character = new_dict.character
	new_turn_prev.asked_player_index = new_dict.asked_player_index
	new_turn_prev.tile = Vector2i(new_dict.tile[0], new_dict.tile[1])
	return new_turn_prev
