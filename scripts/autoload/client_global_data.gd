extends Node

## Stores the IDs of clients that have been logged in and their basic user info
## [codeblock]
## {
##	"id": "1",
##	"user_name": "Javibu13",
##	"": "Javibu13"
## }
## [/codeblock]
var user_info: Dictionary[String, Variant] = {}
var lobby_joined: String = ""
var lobby_size_status: String = ""
var match_id: int = 0
var public_game: PublicGame
var is_local_player_turn: bool = false

func storeUserInfo(user_info_to_store: Dictionary):
	user_info["nickname"] = user_info_to_store["nickname"]
	user_info["id"] = user_info_to_store["id"]
	user_info["email"] = user_info_to_store["email"]


func resetLobbyData() -> void:
	lobby_joined = ""
	lobby_size_status = ""
