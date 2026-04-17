extends Node

## Stores the games that are currently being played using the DB game_id
## [codeblock]
## {
##	112334: Game
##	112335: Game
## }
## [/codeblock]
var games: Dictionary[int, Game] = {}


# Creates an entry in DB for the match and get the generated ID to create the main data structure for the match in the server side
func create_db_match_and_get_id(match_type: ServerGlobalData.LobbyType) -> int:
	var new_match := DatabaseManager.match_game.create_new(ServerGlobalData.VERSION, match_type)
	return new_match.id if not new_match.is_empty() else 0


# Create and configure the new match
func set_up_match(match_id: int, clients_id: Array[int]) -> void:
	# TODO: CONTINUE HERE
	pass
