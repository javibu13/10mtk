extends Node


signal initial_info_received(public_game: PublicGame)


# Send to client the initial info needed to set up everything to start first turn
@rpc("authority", "call_remote", "reliable")
func client_send_initial_info(public_game_info: Dictionary):
	print("------------------------", public_game_info)
	initial_info_received.emit(PublicGame.from_dict(public_game_info))


# Notify server that the player is ready to start the match after game set up
@rpc("any_peer", "call_remote", "reliable")
func server_notify_client_ready_to_start_match(match_id: int):
	# Get the ID of the client who requested the server process
	var client_id := multiplayer.get_remote_sender_id()
	# Set the ready property for the player in the game
	var player_index = ServerGameData.games[match_id].public.players.find_custom(func(player: Player): return player.client_id == client_id)
	if player_index < 0:
		# TODO: Control the error: Client_id is not assigned to the game that has been sent with the ready request
		return
	ServerGameData.games[match_id].public.players[player_index].ready = true
	print(str("Player ", player_index, " (", client_id, ") is ready to start the game..."))
	# Check if all the players are ready or not
	if ServerGameData.games[match_id].public.players.all(func(player: Player): return player.ready):
		# Send notification to start with the first turn
		print("FIRST TURN STARTS!!!")
