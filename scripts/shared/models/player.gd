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


func _init(new_client_id: int, new_user_name: String, new_index: int, new_assassin: Enums.Character, new_objectives: Array[Enums.Character]) -> void:
	client_id = new_client_id
	user_name = new_user_name
	ready = false
	index = new_index
	assassin = new_assassin
	objectives = new_objectives


func generate_initial_public_version() -> Player:
	return Player.new(0, user_name, index, Enums.Character.NONE, [Enums.Character.NONE, Enums.Character.NONE, Enums.Character.NONE])


func to_dict() -> Dictionary:
	return {
		"client_id": client_id,
		"user_name": user_name,
		"index": index,
		"kills": kills,
		"assassin": assassin,
		"objectives": objectives,
		"arrests": arrests,
		"status": status,
	}
