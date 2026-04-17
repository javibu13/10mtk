extends Node

enum LobbyType {
	QUICK,
	CUSTOM,
}

const MAX_PLAYERS_PER_GAME = 2
const VERSION : String = "v0.0.1"

var http_request: HTTPRequest = HTTPRequest.new()
var config_reader = ConfigFile.new()
var api_email := {}
## Stores the IDs of clients that have been logged in and their basic user info
## [codeblock]
## {
##	471290087: {
##				"db_id": 28
##				"user_name": "Montse",
##				"nickname": "mgoon13",
##				"email": "false@email.tk",
##				},
##	1416429352: {
##				"db_id": 9
##				"user_name": "Javier",
##				"nickname": "Javibu13",
##				"email": "superfalse@email.tk",
##				}
## }
## [/codeblock]
var logged_in_users: Dictionary[int, Dictionary] = {}
## Stores the lobbies that are being filled up with players to create a new match
## [codeblock]
## {
##	2f4d5th9sj4cug514g3d7eg6x8th4f2v: {
##				"players": [471290087, 1416429352],
##				"game_accepted": {
##					471290087: true,
##					471290087: false,
##				}
##				"max_players": 4,
##				"type": LobbyType.QUICK,
##				},
##	14g3d7eg6x8th4f2v2f4d5th9sj4cug5: {
##				"players": [2416429352, 371290087],
##				"game_accepted": {
##					2416429352: false,
##					371290087: false,
##				}
##				"max_players": 3,
##				"type": LobbyType.CUSTOM,
##				}
## }
## [/codeblock]
var lobbies: Dictionary[String, Dictionary] = {}
var available_lobbies_quick: Array[String] = []
var available_lobbies_custom: Array[String] = []


func _ready() -> void:
	_read_config_file()
	NetworkManager.player_disconnected.connect(remove_logged_in_user)


# Used to read the config file with important data to setup and private info/keys
func _read_config_file():
	# TODO: Change path by "user://" for production env
	var result = config_reader.load("res://.env.cfg")
	if result != OK:
		push_error("Config file not found")
		return
	api_email.key = config_reader.get_value("api", "email_key", "")
	api_email.secret = config_reader.get_value("api", "email_secret", "")
	api_email.url = config_reader.get_value("api", "email_url", "")
	api_email.sender_email = config_reader.get_value("api", "email_sender_email", "")
	api_email.sender_name = config_reader.get_value("api", "email_sender_name", "")
	if api_email.key == "":
		push_error("Email API key not found in config file")
	if api_email.secret == "":
		push_error("Email API secret not found in config file")
	if api_email.url == "":
		push_error("API URL not found in config file")
	if api_email.sender_email == "":
		push_error("API sender email not found in config file")
	if api_email.sender_name == "":
		push_error("API sender name not found in config file")


# Send email using External API to user who asked for password reset
func send_reset_password_email(user_email: String, user_name: String, new_password: String) -> bool:
	# Build request body for Mailjet API v3.1
	var body = {
		"SandboxMode": false,
		"Messages": [
			{
				"From": {
					"Email": api_email.sender_email,
					"Name": api_email.sender_name,
				},
				"To": [
					{
						"Email": user_email,
						"Name": user_name,
					}
				],
				"Subject": "10' To Kill - Password Reset",
				"TextPart": "10' To Kill\n\nNew Password:\n" + new_password,
			},
		],
	}
	# Needed headers for Mailjet API v3.1
	var auth_raw = api_email.key + ":" + api_email.secret
	var auth_bytes = auth_raw.to_utf8_buffer()
	var auth_token = Marshalls.raw_to_base64(auth_bytes)
	var headers = [
		"Authorization: Basic " + auth_token,
		"Content-Type: application/json"
	]
	# Execute http request
	var json_body = JSON.stringify(body)
	var response = http_request.request(api_email.url, headers, HTTPClient.METHOD_POST, json_body)
	if response != OK:
		#print("ERROR SENDING EMAIL: ", response)
		NetworkManager.server_print_msg.emit("ERROR SENDING EMAIL: " + str(response))
		return false
	# Wait for request completed
	var response_completed = await http_request.request_completed
	NetworkManager.server_print_msg.emit(str(response_completed))
	# response = [result, response_code, headers, body]
	var response_completed_result = response_completed[0]
	var response_completed_response_code = response_completed[1]
	
	if response_completed_result == HTTPRequest.RESULT_SUCCESS and (response_completed_response_code == 200 || response_completed_response_code == 201 || response_completed_response_code == 202):
		#print("SUCCESSFUL EMAIL!!")
		NetworkManager.server_print_msg.emit("SUCCESSFUL EMAIL!!")
		return true
	else:
		var response_text = response_completed[3].get_string_from_utf8()
		#print("Error response: ", response_text)
		NetworkManager.server_print_msg.emit("Error response: " + str(response_text))
		return false


# Remove client_id and its previous info saved at loggin from logged_in_users dictionary
func remove_logged_in_user(client_id) -> void:
	if not logged_in_users.erase(client_id):
		NetworkManager.server_print_msg.emit(str("⚠️ Trying to remove the logged_in_user info of a nonexistant client_id (", client_id, ")"))


# Check if given client_id is already joined to any lobby or game
func check_client_id_already_joined_or_playing(client_id: int) -> bool:
	var is_in_lobby = lobbies.values().any(func(lobby): return lobby.players.has(client_id))
	#var is_in_game = false # TODO: Check if client_id is playing a game
	return is_in_lobby


# Get the oldest quick lobby id to fill up
func get_quick_lobby_available() -> String:
	var lobby_id := ""
	for available_lobby_id in available_lobbies_quick:
		if lobbies.has(available_lobby_id) and lobbies[available_lobby_id].players.size() < lobbies[available_lobby_id].max_players:
			lobby_id = available_lobby_id
			break
	return lobby_id


# Add player to lobby. Returns true if there is more space available in the lobby and false if the lobby is full after join player
func add_player_to_lobby(client_id: int, lobby_id: String) -> bool:
	lobbies[lobby_id].players.append(client_id)
	return lobbies[lobby_id].players.size() < lobbies[lobby_id].max_players


# Remove player from the lobby that is joined. Returns true if the lobby is empty after player removal
func remove_player_from_lobby(client_id: int, lobby_id: String = "") -> bool:
	if not lobby_id:
		lobby_id = get_lobby_of_client(client_id)
	if not lobby_id:
		NetworkManager.server_print_msg.emit(str("❌ Client (", client_id, ") is not found in any lobby"))
		return false
	lobbies[lobby_id].players.erase(client_id)
	lobbies[lobby_id].game_accepted.erase(client_id)
	return lobbies[lobby_id].players.is_empty()


func get_lobby_of_client(client_id: int) -> String:
	var joined_lobby_id = ""
	for lobby_id in lobbies.keys():
		if lobbies[lobby_id].players.has(client_id):
			joined_lobby_id = lobby_id
			break
	return joined_lobby_id


# Create new lobby and return its id
func create_new_lobby(type: LobbyType, max_players: int = MAX_PLAYERS_PER_GAME) -> String:
	var lobby_id = Utils.generate_uuid()
	lobbies[lobby_id] = {
		"players": [],
		"game_accepted": {},
		"max_players": max_players,
		"type": type,
	}
	match type:
		LobbyType.QUICK:
			available_lobbies_quick.append(lobby_id)
		LobbyType.CUSTOM:
			available_lobbies_custom.append(lobby_id)
	return lobby_id


# Remove lobby. Returns true if it has been removed or false if it was not empty and it could not be removed
func remove_lobby(lobby_id: String) -> bool:
	if lobbies.has(lobby_id) and lobbies[lobby_id].players.is_empty():
		lobbies.erase(lobby_id)
		return true
	else:
		if lobbies.has(lobby_id):
			NetworkManager.server_print_msg.emit(str("❌ Error trying to remove lobby ", lobby_id, " NOT EMPTY"))
		else:
			NetworkManager.server_print_msg.emit(str("❌ Error trying to remove lobby ", lobby_id, " NOT FOUND IN LOBBIES"))
		return false

# Check if all players joined to a lobby have answered to game start request (it does not check if they have answered "accept" or "reject")
func check_if_all_clients_answered_game_start(lobby_id: String) -> bool:
	return lobbies[lobby_id].players.size() == lobbies[lobby_id].game_accepted.size()
