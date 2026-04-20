class_name PrivateGame
extends RefCounted


var players: Array[Player] = []
var client_ids_and_match_player_ids: Dictionary[int, int] = {}
var turn_history: Array[TurnResult] = []


func _init(new_players: Array[Player], new_client_ids_and_match_player_ids: Dictionary[int, int]) -> void:
	players = new_players
	client_ids_and_match_player_ids = new_client_ids_and_match_player_ids
	# Store in db the assigned data to match_player
	for player in players:
		DatabaseManager.match_player.update_by_id(client_ids_and_match_player_ids[player.client_id], player.assassin, Enums.PlayerStatus.LIVE)
		for objective in player.objectives:
			DatabaseManager.match_player_objective.create_new(client_ids_and_match_player_ids[player.client_id], objective)
