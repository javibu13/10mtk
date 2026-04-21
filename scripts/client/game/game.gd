extends Node3D

signal tile_resource_loaded
signal token_character_resource_loaded
signal board_built
signal public_data_received


const TILE_SCENE_PATH = "res://scenes/game/Tile.tscn"
const TOKEN_CHARACTER_SCENE_PATH = "res://scenes/game/TokenCharacterBase.tscn"


var tile_resource: Resource
var token_character_resource: Resource


@onready var board_3d: Board3D = $Board3D
@onready var loading_screen_control: Control = $CanvasLayer/LoadingScreen_Control


func _ready() -> void:
	# Check if ClientGlobalData.public_game has received the game_info to set up the beginning of the match (board, characters, ui...)
	if ClientGlobalData.public_game != null:
		# Launch game set up
		_public_data_received()
	else:
		GameManager.initial_info_received.connect(_public_data_received)
	# Load tile scene
	ResourceLoader.load_threaded_request(TILE_SCENE_PATH)
	ResourceLoader.load_threaded_request(TOKEN_CHARACTER_SCENE_PATH)


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if not tile_resource:
		tile_resource = _check_load_threaded_request(TILE_SCENE_PATH, tile_resource_loaded)
	if not token_character_resource:
		token_character_resource = _check_load_threaded_request(TOKEN_CHARACTER_SCENE_PATH, token_character_resource_loaded)
	if tile_resource and token_character_resource and ClientGlobalData.public_game:
		board_3d.tile_resource = tile_resource
		board_3d.generate_board(ClientGlobalData.public_game.board)
		loading_screen_control.hide()
		set_process(false)

func _public_data_received() -> void:
	public_data_received.emit()


func _check_load_threaded_request(scene_path: String, signal_completed: Signal) -> Resource:
	var request_result: Resource
	var status = ResourceLoader.load_threaded_get_status(scene_path)
	match status:
		ResourceLoader.THREAD_LOAD_LOADED:
			request_result = ResourceLoader.load_threaded_get(scene_path)
			signal_completed.emit()
		ResourceLoader.THREAD_LOAD_FAILED:
			push_error(str("Error loading ", scene_path))
	return request_result
