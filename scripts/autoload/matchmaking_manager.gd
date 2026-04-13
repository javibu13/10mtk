extends Node

signal join_client_to_quick_lobby_failed(message)
signal request_accept_match_start(countdown_timer)
signal return_to_quick_mode_search
signal kicked_from_quick_mode_search_to_main_menu

const COUNTDOWN_TIME := 10

# Request for server to join client to a quick type lobby
@rpc("any_peer", "call_remote", "reliable")
func server_join_client_to_quick_lobby():
	# Get the ID of the client who requested the server process
	var client_id := multiplayer.get_remote_sender_id()
	# Check if client_id is free to be added to some lobby
	if ServerGlobalData.check_client_id_already_joined_or_playing(client_id):
		var error_message = "Client is waiting in other lobby or playing a game"
		client_join_client_to_quick_lobby_response.rpc_id(client_id, false, error_message)
		return
	# Get available lobby or create new if none is available
	var lobby_id = ServerGlobalData.get_quick_lobby_available()
	if not lobby_id:
		# Create new lobby with the max default players
		lobby_id = ServerGlobalData.create_new_lobby(ServerGlobalData.LobbyType.QUICK)
		NetworkManager.server_print_msg.emit(str("New lobby created: ", lobby_id))
	# Add client to lobby
	var is_space_available = ServerGlobalData.add_player_to_lobby(client_id, lobby_id)
	NetworkManager.server_print_msg.emit(str("Client (", client_id,") joined lobby (", lobby_id,")"))
	# Send response to client and give the lobby_id for future updates and operations
	client_join_client_to_quick_lobby_response.rpc_id(client_id, true, lobby_id)
	# Send update about the number of joined players to every client waiting in this lobby
	for client_id_joined_to_lobby in ServerGlobalData.lobbies[lobby_id].players:
		client_update_joined_players_to_quick_lobby.rpc_id(client_id_joined_to_lobby, str(ServerGlobalData.lobbies[lobby_id].players.size(), "/", ServerGlobalData.lobbies[lobby_id].max_players))
	# If the lobby is full, try to start game asking clients if they accept the match
	if not is_space_available:
		#TODO: Get id of clients in the lobby to ask for game start
		NetworkManager.server_print_msg.emit(str("Lobby ", lobby_id, " is ready to start the match with players: ", ServerGlobalData.lobbies[lobby_id].players))
		for client_id_joined_to_lobby in ServerGlobalData.lobbies[lobby_id].players:
			client_request_accept_match_start.rpc_id(client_id_joined_to_lobby, COUNTDOWN_TIME)


@rpc("authority", "call_remote", "reliable")
func client_join_client_to_quick_lobby_response(success: bool, message: String):
	print(str("Joined to lobby: ", message))
	if success:
		ClientGlobalData.lobby_joined = message
	else:
		ClientGlobalData.lobby_joined = ""
		join_client_to_quick_lobby_failed.emit(message)


@rpc("authority", "call_remote", "reliable")
func client_update_joined_players_to_quick_lobby(lobby_size_status: String):
	ClientGlobalData.lobby_size_status = lobby_size_status


# Request for server to make the client leave the lobby
@rpc("any_peer", "call_remote", "reliable")
func server_client_leaves_lobby():
	# Get the ID of the client who requested the server process
	var client_id := multiplayer.get_remote_sender_id()
	# Remove player from lobby
	var lobby_id = ServerGlobalData.get_lobby_of_client(client_id)
	if not lobby_id:
		NetworkManager.server_print_msg.emit(str("⚠️ Client ", client_id, " tries to leave a lobby that does not exist"))
		return
	var is_lobby_empty = ServerGlobalData.remove_player_from_lobby(client_id, lobby_id)
	if is_lobby_empty:
		# Remove empty lobby
		ServerGlobalData.remove_lobby(lobby_id)
	else:
		# Update lobby size info to the still joined players
		for client_id_joined_to_lobby in ServerGlobalData.lobbies[lobby_id].players:
			client_update_joined_players_to_quick_lobby.rpc_id(client_id_joined_to_lobby, str(ServerGlobalData.lobbies[lobby_id].players.size(), "/", ServerGlobalData.lobbies[lobby_id].max_players))


# Emit signal in client to start the process of accept/decline match
@rpc("authority", "call_remote", "reliable")
func client_request_accept_match_start(countdown_timer: int):
	request_accept_match_start.emit(countdown_timer)


# Client accepts the match
@rpc("any_peer", "call_remote", "reliable")
func server_client_accepts_match():
	# Get the ID of the client who requested the server process
	var client_id := multiplayer.get_remote_sender_id()
	# Get the lobby id where the client is joined
	var lobby_id := ServerGlobalData.get_lobby_of_client(client_id)
	if not lobby_id:
		NetworkManager.server_print_msg.emit("❌ Client ", client_id, " tries to accept a game start without being joined to any lobby")
		return
	ServerGlobalData.lobbies[lobby_id].game_accepted[client_id] = true
	if ServerGlobalData.check_if_all_clients_answered_game_start(lobby_id):
		# Check which clients have accepted the game start and which have rejected it
		var reject_clients_id := []
		var accept_clients_id := []
		for answered_client_id in ServerGlobalData.lobbies[lobby_id].game_accepted:
			if ServerGlobalData.lobbies[lobby_id].game_accepted[answered_client_id]:
				# ✅ Accepted the game start
				accept_clients_id.append(answered_client_id)
			else:
				# ❌ Rejected the game start
				reject_clients_id.append(answered_client_id)
		if reject_clients_id.is_empty():
			# TODO: START GAME!!!
			NetworkManager.server_print_msg.emit(str("START GAME FOR LOBBY ", lobby_id))
		else:
			# Some client has rejected the game start. Kick them from lobby and keep the others
			for reject_client_id in reject_clients_id:
				# Kick the player and remove the lobby if it is empty (only possible if all clients rejected the game start)
				if ServerGlobalData.remove_player_from_lobby(reject_client_id, lobby_id):
					ServerGlobalData.remove_lobby(lobby_id)
				client_kick_from_quick_match_search.rpc_id(reject_client_id)
			if not accept_clients_id.is_empty():
				for accept_client_id in accept_clients_id:
					client_return_to_quick_match_search.rpc_id(accept_client_id)
				for client_id_still_joined_to_lobby in ServerGlobalData.lobbies[lobby_id].players:
					client_update_joined_players_to_quick_lobby.rpc_id(client_id_still_joined_to_lobby, str(ServerGlobalData.lobbies[lobby_id].players.size(), "/", ServerGlobalData.lobbies[lobby_id].max_players))


# Client rejects the match
@rpc("any_peer", "call_remote", "reliable")
func server_client_rejects_match():
	# Get the ID of the client who requested the server process
	var client_id := multiplayer.get_remote_sender_id()
	# Get the lobby id where the client is joined
	var lobby_id := ServerGlobalData.get_lobby_of_client(client_id)
	if not lobby_id:
		NetworkManager.server_print_msg.emit("❌ Client ", client_id, " tries to reject a game start without being joined to any lobby")
		return
	ServerGlobalData.lobbies[lobby_id].game_accepted[client_id] = false
	if ServerGlobalData.check_if_all_clients_answered_game_start(lobby_id):
		# Check which clients have accepted the game start and which have rejected it
		var reject_clients_id := []
		var accept_clients_id := []
		for answered_client_id in ServerGlobalData.lobbies[lobby_id].game_accepted:
			if ServerGlobalData.lobbies[lobby_id].game_accepted[answered_client_id]:
				# ✅ Accepted the game start
				accept_clients_id.append(answered_client_id)
			else:
				# ❌ Rejected the game start
				reject_clients_id.append(answered_client_id)
		# Some client has rejected the game start. Kick them from lobby and keep the others
		for reject_client_id in reject_clients_id:
			# Kick the player and remove the lobby if it is empty (only possible if all clients rejected the game start)
			if ServerGlobalData.remove_player_from_lobby(reject_client_id, lobby_id):
				ServerGlobalData.remove_lobby(lobby_id)
			client_kick_from_quick_match_search.rpc_id(reject_client_id)
		if not accept_clients_id.is_empty():
			for accept_client_id in accept_clients_id:
				client_return_to_quick_match_search.rpc_id(accept_client_id)
			for client_id_still_joined_to_lobby in ServerGlobalData.lobbies[lobby_id].players:
				client_update_joined_players_to_quick_lobby.rpc_id(client_id_still_joined_to_lobby, str(ServerGlobalData.lobbies[lobby_id].players.size(), "/", ServerGlobalData.lobbies[lobby_id].max_players))


# Return client to the previous quick match search maintaining the previous lobby too
@rpc("authority", "call_remote", "reliable")
func client_return_to_quick_match_search():
	return_to_quick_mode_search.emit()


@rpc("authority", "call_remote", "reliable")
func client_kick_from_quick_match_search():
	kicked_from_quick_mode_search_to_main_menu.emit()
