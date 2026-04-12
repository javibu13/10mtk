extends Node

signal join_client_to_quick_lobby_failed(message)

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
	var is_lobby_empty = ServerGlobalData.remove_player_from_lobby(client_id, lobby_id)
	if is_lobby_empty:
		# Remove empty lobby
		ServerGlobalData.remove_lobby(lobby_id)
	else:
		# Update lobby size info to the still joined players
		for client_id_joined_to_lobby in ServerGlobalData.lobbies[lobby_id].players:
			client_update_joined_players_to_quick_lobby.rpc_id(client_id_joined_to_lobby, str(ServerGlobalData.lobbies[lobby_id].players.size(), "/", ServerGlobalData.lobbies[lobby_id].max_players))
