extends Node


signal initial_info_received(public_game: PublicGame)
signal new_turn_received


# Send to client the initial info needed to set up everything to start first turn
@rpc("authority", "call_remote", "reliable")
func client_send_initial_info(public_game_info: Dictionary):
	ClientGlobalData.public_game = PublicGame.from_dict(public_game_info)
	initial_info_received.emit()


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
	Log.pr(str("Player ", player_index, " (", client_id, ") has set up everything and is ready to start the game..."))
	# Check if all the players are ready or not
	if ServerGameData.games[match_id].public.players.all(func(player: Player): return player.ready):
		# Send notification to start with the first turn
		for player in ServerGameData.games[match_id].public.players:
			client_send_new_turn.rpc_id(player.client_id, ServerGameData.games[match_id].public.to_dict(player.client_id))


# Send to clients the new turn update
@rpc("authority", "call_remote", "reliable")
func client_send_new_turn(public_game_info: Dictionary):
	Log.pr("NEW TURN RECEIVED signal emit!")
	ClientGlobalData.public_game = PublicGame.from_dict(public_game_info)
	new_turn_received.emit()


# Send to server the turn result info
@rpc("any_peer", "call_remote", "reliable")
func server_send_turn_result(match_id: int, turn_result_dict: Dictionary):
	var turn_result: TurnResult = TurnResult.from_dict(turn_result_dict)
	# Check if this is the player and action number expected to accept the turn_result and if the match_id is correct
	# TODO: ↑
	# Apply action from turn result
	match turn_result.action:
		Enums.Action.NONE:
			# Turn skipped
			pass
		Enums.Action.MOVE:
			# Move character from current tile to objective tile
			ServerGameData.games[match_id].public.board.move_character_to_tile(turn_result.character, turn_result.tile)
		Enums.Action.KILL:
			# Remove character from current tile
			ServerGameData.games[match_id].public.board.remove_character(turn_result.character)
			# Add killed character to player's kill list in both types of game data info (public and private)
			ServerGameData.games[match_id].add_character_kill_to_player(turn_result.character, turn_result.player_index)
			# Check if killed character was assigned as assassin or objective of any player to make it public
			var killed_assign_type_character := ServerGameData.games[match_id].try_to_discover_character(turn_result.character)
			# TODO: Store in DB the character kill for player
			# TODO: Move characters in the tile where the kill was made to random positions
			# TODO: Add a police to the now empty tile where the kill was made
		Enums.Action.ASK:
			# Check if asked player's assassin is the selected character
			var is_assassin_discovered := ServerGameData.games[match_id].apply_ask_to_player(turn_result.player_index, turn_result.character, turn_result.asked_player_index)
			if is_assassin_discovered:
				# TODO: Store in DB the arrest
				pass
	# Store in DB the turn result (if there was a kill, store the resulted characters' locations in board to know where the characters in the same tile of the kill went)
	# TODO: ↑
	# Generate new turn	
	var new_action_number: int = 2 if turn_result.action_number == 1 else 1
	var new_player_index: int = turn_result.player_index
	if new_action_number == 1:
		new_player_index = turn_result.player_index + 1 if turn_result.player_index + 1 < ServerGameData.games[match_id].private.players.size() else 0
	var new_turn: Turn = Turn.server_new(new_player_index, new_action_number, ServerGameData.TIME_PER_TURN, turn_result)
	ServerGameData.games[match_id].public.turn = new_turn
	for player in ServerGameData.games[match_id].public.players:
		client_send_new_turn.rpc_id(player.client_id, ServerGameData.games[match_id].public.to_dict(player.client_id))
