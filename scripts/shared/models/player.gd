class_name Player
extends RefCounted

var client_id: int
var user_name: String
var ready: bool
## Used for turn order
var index: int
var kills: Array[Enums.Character] = []
var assassin: Enums.Character = Enums.Character.NONE
var objectives: Array[Enums.Character] = []
var arrests: Array[Enums.Character] = []
var status: Enums.PlayerStatus = Enums.PlayerStatus.LIVE


static func server_new(new_client_id: int, new_user_name: String, new_index: int, new_assassin: Enums.Character, new_objectives: Array[Enums.Character]) -> Player:
	var new_player: Player = Player.new()
	new_player.client_id = new_client_id
	new_player.user_name = new_user_name
	new_player.ready = false
	new_player.index = new_index
	new_player.assassin = new_assassin
	new_player.objectives = new_objectives
	return new_player


func generate_initial_public_version() -> Player:
	# TODO: Client_id could be private for all clients but for the client with the exact client_id
	return Player.server_new(client_id, user_name, index, Enums.Character.NONE, [Enums.Character.NONE, Enums.Character.NONE, Enums.Character.NONE])


func to_dict() -> Dictionary:
	return {
		"client_id": client_id,
		"user_name": user_name,
		"ready": ready,
		"index": index,
		"kills": kills,
		"assassin": assassin,
		"objectives": objectives,
		"arrests": arrests,
		"status": status,
	}


# Create object using dictionary and basic data type structure
static func from_dict(new_dict: Dictionary) -> Player:
	var new_player: Player = Player.new()
	new_player.client_id = new_dict.client_id
	new_player.user_name = new_dict.user_name
	new_player.ready = new_dict.ready
	new_player.index = new_dict.index
	new_player.kills = new_dict.kills
	new_player.assassin = new_dict.assassin
	new_player.objectives = new_dict.objectives
	new_player.arrests = new_dict.arrests
	new_player.status = new_dict.status
	return new_player
