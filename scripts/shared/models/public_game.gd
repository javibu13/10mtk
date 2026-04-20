class_name PublicGame
extends RefCounted


var game_id: int
var board: Board
var players: Array[Player] = []
var turn: Turn
var time_per_turn: int


func _init(new_game_id: int, public_players: Array[Player], characters_to_place: Array[int], new_time_per_turn: int) -> void:
	game_id = new_game_id
	players = public_players
	@warning_ignore("integer_division") # It's known that the division result will be the integer part of the result and this is the desired number
	board = Board.new(characters_to_place, characters_to_place.size(), characters_to_place.size()/2)
	turn = Turn.new(0, Enums.ActionNumber.FIRST, new_time_per_turn)


# Transform object (and its content) into a dictionary
func to_dict() -> Dictionary:
	return {
		"game_id": game_id,
		"board": board.to_dict(),
		"players": players.map(func(player): return player.to_dict()),
		"turn": turn.to_dict(),
		"time_per_turn": time_per_turn
	}


# Create objectusing dictionary and basic data type structure
static func from_dict(new_dict: Dictionary) -> PublicGame:
	# TODO: This is a place holder object creation
	return PublicGame.new(new_dict.game_id, new_dict.public_players, new_dict.characters, new_dict.time_per_turn)
