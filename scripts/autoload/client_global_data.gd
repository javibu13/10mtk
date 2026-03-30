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

func storeUserInfo(user_info_to_store: Dictionary):
	user_info["nickname"] = user_info_to_store["nickname"]
	user_info["id"] = user_info_to_store["id"]
	user_info["email"] = user_info_to_store["email"]	
