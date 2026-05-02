class_name Game
extends RefCounted

var public: PublicGame
var private: PrivateGame

func _init(match_id: int, client_ids_and_match_player_ids: Dictionary[int, int]) -> void:
	var shuffled_clients_id := client_ids_and_match_player_ids.keys()
	shuffled_clients_id.shuffle()
	var characters_to_assign := Enums.Character.values()
	# Remove police characters (and NONE = 0) from list of characters because this list will be used for assassins and objectives assignments
	for police in Enums.Character_Police.values():
		characters_to_assign.erase(police)
	# Duplicate to keep and use it later
	var characters_to_place: Array[int] = []
	characters_to_place.assign(characters_to_assign.duplicate())
	var players: Array[Player] = []
	for shuffled_client_index in range(shuffled_clients_id.size()):
		var client_id = shuffled_clients_id[shuffled_client_index]
		var user_name = ServerGlobalData.logged_in_users[client_id].user_name
		var assassin = characters_to_assign.pick_random()
		characters_to_assign.erase(assassin)
		var objectives: Array[Enums.Character] = [Enums.Character.NONE, Enums.Character.NONE, Enums.Character.NONE]
		for objective_index in range(objectives.size()):
			objectives[objective_index] = characters_to_assign.pick_random()
			characters_to_assign.erase(objectives[objective_index])
		players.append(Player.server_new(client_id, user_name, shuffled_client_index, assassin, objectives))
	private = PrivateGame.new(players, client_ids_and_match_player_ids)
	var public_players: Array[Player] = []
	public_players.assign(players.map(func (player: Player): return player.generate_initial_public_version()))
	public = PublicGame.server_new(match_id, public_players, characters_to_place, ServerGameData.TIME_PER_TURN)
	# Store map_display in database
	DatabaseManager.match_game.update_map_display_by_id(match_id, public.board.to_dict())


func add_character_kill_to_player(character: Enums.Character, player_index: int) -> void:
	public.players[player_index].kills.append(character)
	private.players[player_index].kills.append(character)


## Search among every player's assassin and objectives to check if the character is assigned to them. Updates public player if the character was assigned in private player and returns the info of which type of character assign was it. Enums.DiscoveredCharacter.NONE if the character was not assigned to any player 
func try_to_discover_character(character: Enums.Character) -> Enums.DiscoveredCharacter:
	for player in private.players:
		if player.assassin == character:
			public.players[player.index].assassin = character
			return Enums.DiscoveredCharacter.ASSASSIN
		if character in player.objectives:
			var objective_index = player.objectives.find_custom(func(objective_character: Enums.Character): return character == objective_character)
			public.players[player.index].objectives[objective_index] = character
			return Enums.DiscoveredCharacter.OBJECTIVE
	return Enums.DiscoveredCharacter.NONE


## Check if the player's assassin is the character that is being asked. If it is correct, the character is revealed in public info and added as an arrested character to the player who asked
func apply_ask_to_player(player_index: int, character: Enums.Character, asked_player_index: int) -> bool:
	if private.players[asked_player_index].assassin == character:
		public.players[asked_player_index].assassin = character
		public.players[player_index].arrests.append(character)
		private.players[player_index].arrests.append(character)
		return true
	else:
		return false
