class_name Tile
extends RefCounted


var location: Vector2i
# Dictionary used to make characters unique in the tile. The key stores the character "id" and value is not used (true by default)
var characters: Dictionary[Enums.Character, bool] = {}
# Same as characters
var polices: Dictionary[Enums.Character, bool] = {}
var type: Enums.TileType


static func server_new(new_location: Vector2i, character: Enums.Character, is_sniper: bool) -> Tile:
	var new_tile: Tile = Tile.new()
	new_tile.location = new_location
	new_tile.characters[character] = true
	new_tile.type = Enums.TileType.COMMON if not is_sniper else Enums.TileType.SNIPER
	return new_tile


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


# Create object using dictionary and basic data type structure
static func from_dict(new_dict: Dictionary) -> Tile:
	var new_tile: Tile = Tile.new()
	new_tile.location = Vector2i(new_dict.location[0], new_dict.location[1])
	new_tile.characters = new_dict.characters
	new_tile.polices = new_dict.polices
	new_tile.type = new_dict.type
	return new_tile


func get_characters_and_police() -> Array[Enums.Character]:
	var token_characters: Array[Enums.Character] = []
	token_characters.append_array(characters.keys())
	token_characters.append_array(polices.keys())
	return token_characters
