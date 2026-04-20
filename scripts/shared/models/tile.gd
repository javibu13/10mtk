class_name Tile
extends RefCounted


var location: Vector2i
# Dictionary used to make characters unique in the tile. The key stores the character "id" and value is not used (true by default)
var characters: Dictionary[Enums.Character, bool] = {}
# Same as characters
var polices: Dictionary[Enums.Character, bool] = {}
var type: Enums.TileType


func _init(new_location: Vector2i, character: Enums.Character, is_sniper: bool) -> void:
	location = new_location
	characters[character] = true
	type = Enums.TileType.COMMON if not is_sniper else Enums.TileType.SNIPER


func set_type_sniper() -> void:
	type = Enums.TileType.SNIPER


func set_type_common() -> void:
	type = Enums.TileType.COMMON


func to_dict() -> Dictionary:
	return {
		"location": [location.x, location.y],
		"characters": characters,
		"polices": polices,
		"type": type
	}
