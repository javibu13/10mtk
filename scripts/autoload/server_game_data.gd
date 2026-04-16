extends Node

## Stores the games that are currently being played using the DB game_id
## [codeblock]
## {
##	112334: Game
##	112335: Game
## }
## [/codeblock]
var games: Dictionary[int, Game] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
