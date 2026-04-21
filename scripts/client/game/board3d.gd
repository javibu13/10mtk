extends Node3D

class_name Board3D

@export var cameraController : CameraInputs3D
var tile_resource: Resource
var board : Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#_fillBoard()
	#cameraController.selectSquare(board[0][0])


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


# Create sample initial square
#func sample_tile_generation():
	#board[0] = { 0 : tile_resource.instantiate()}
	#add_child(board[0][0])
	#board[0][0].place(Vector2(0,0))
	#board[0][0].setSniper()
