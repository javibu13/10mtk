class_name TurnResult
extends TurnPrev


static func client_new(current_player_index: int, current_action_number: Enums.ActionNumber, left_time: int, new_action: Enums.Action, objective_character: Enums.Character, new_asked_player_index: int = -1, new_tile: Vector2i = Vector2i.ZERO) -> TurnResult:
	var turn_action := TurnResult.new()
	var current_turn := Turn.server_new(current_player_index, current_action_number, left_time)
	turn_action.player_index = current_turn.player_index
	turn_action.action_number = current_turn.action_number
	turn_action.time = current_turn.time
	turn_action.action = new_action
	turn_action.character = objective_character
	turn_action.asked_player_index = new_asked_player_index
	turn_action.tile = new_tile
	return turn_action


static func from_turn_prev(turn_prev: TurnPrev) -> TurnResult:
	var turn_result = TurnResult.new()
	turn_result.player_index = turn_prev.player_index
	turn_result.action_number = turn_prev.action_number
	turn_result.time = turn_prev.time
	turn_result.action = turn_prev.action
	turn_result.character = turn_prev.character
	turn_result.asked_player_index = turn_prev.asked_player_index
	turn_result.tile = turn_prev.tile
	return turn_result


static func from_dict(new_dict: Dictionary) -> TurnResult:
	return TurnResult.from_turn_prev(super.from_dict(new_dict))
