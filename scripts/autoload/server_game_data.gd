extends Node


const TIME_PER_TURN = 30


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
func set_up_match(match_id: int, new_client_ids_and_match_player_ids: Dictionary[int, int]) -> void:
	if games.has(match_id):
		# TODO: Control this error
		return
	games[match_id] = Game.new(match_id, new_client_ids_and_match_player_ids)


# Create match_player entries for each client joined to the match that is going to be started
func create_db_match_player_entries(new_match_id: int, accept_clients_id: Array[int]) -> Dictionary[int, int]:
	var clients_and_match_player_ids: Dictionary[int, int] = {}
	for client_id in accept_clients_id:
		var db_new_match_player = DatabaseManager.match_player.create_new(new_match_id, ServerGlobalData.logged_in_users[client_id].id)
		clients_and_match_player_ids[client_id] = db_new_match_player.id
	return clients_and_match_player_ids
