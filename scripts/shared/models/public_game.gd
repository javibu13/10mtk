class_name PublicGame
extends RefCounted


var game_id: int
var board: Board
var players: Array[Player] = []
var turn: Turn
var time_per_turn: int


static func server_new(new_game_id: int, public_players: Array[Player], characters_to_place: Array[int], new_time_per_turn: int) -> PublicGame:
	var public_game: PublicGame = PublicGame.new()
	public_game.game_id = new_game_id
	public_game.players = public_players
	@warning_ignore("integer_division") # It's known that the division result will be the integer part of the result and this is the desired number
	public_game.board = Board.server_new(characters_to_place, characters_to_place.size(), characters_to_place.size()/2)
	public_game.turn = Turn.server_new(0, Enums.ActionNumber.FIRST, new_time_per_turn)
	return public_game


# Transform object (and its content) into a dictionary
func to_dict() -> Dictionary:
	return {
		"game_id": game_id,
		"board": board.to_dict(),
		"players": players.map(func(player): return player.to_dict()),
		"turn": turn.to_dict(),
		"time_per_turn": time_per_turn
	}


# Create object using dictionary and basic data type structure
static func from_dict(new_dict: Dictionary) -> PublicGame:
	var new_public_game: PublicGame = PublicGame.new()
	new_public_game.game_id = new_dict.game_id
	new_public_game.board = Board.from_dict(new_dict.board)
	var new_players: Array[Player] = []
	new_players.append(new_dict.players.map(func(dict_player: Dictionary): return Player.from_dict(dict_player)))
	new_public_game.players = new_players
	new_public_game.turn = Turn.from_dict(new_dict.turn)
	new_public_game.time_per_turn = new_dict.time_per_turn
	return new_public_game
