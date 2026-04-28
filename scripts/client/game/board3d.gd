extends Node3D

class_name Board3D

@export var cameraController : CameraInputs3D
var tile_resource: Resource
var token_character_resource: Resource
var board : Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#_fillBoard()
	#cameraController.select_tile(board[0][0])


func generate_board(new_board: Board) -> void:
	for x in new_board.board.keys():
		for y in new_board.board[x].keys():
			var new_tile: Tile = new_board.board[x][y]
			if not board.has(x):
				board[x] = {}
			var new_tile3d: Tile3D = tile_resource.instantiate()
			add_child(new_tile3d)
			new_tile3d.place(new_tile.location)
			if new_tile.type == Enums.TileType.SNIPER:
				new_tile3d.set_sniper()
			board[x][y] = new_tile3d
			new_tile3d.create_token_character(token_character_resource, new_tile.characters.keys()[0])


# Return the Tile3D where the character is placed
func get_tile3d_of_character(character: Enums.Character) -> Tile3D:
	var character_tile: Tile3D = null
	for tile in get_children(): # TODO: Chenge the iterated collection (and its logic) by the Board.board dictionary stored in PublicGame in ClientGlobalData.public_game
		if tile is Tile3D:
			var token_characters_in_tile: Array[TokenCharacter3D] = tile.get_token_characters()
			for token_character in token_characters_in_tile:
				if token_character.character == character:
					character_tile = tile
					break
			if character_tile:
				break
	return character_tile
