class_name Tile
extends RefCounted

var location: Vector2i
# Dictionary used to make characters unique in the tile. The int will be represented by the Enum.Character
var characters: Dictionary[Enums.Character, bool] = {}
# Same as characters
var polices: Dictionary[Enums.Character, bool] = {}
var type: Enums.TileType
