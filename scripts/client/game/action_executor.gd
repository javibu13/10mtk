extends Node3D
class_name ActionExecutor

signal action_execution_finished

@onready var game_root: GameRootNode = $".."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_up_none_action_process(player_index: int) -> void:
	Log.debug("Action NONE executed for player_index", player_index)
	action_execution_finished.emit.call_deferred()


func set_up_move_action_process(character_to_move: Enums.Character, objective_tile: Vector2i) -> void:
	var current_tile_3d: Tile3D = game_root.board_3d.get_tile3d_of_character(character_to_move)
	var token_character_3d: TokenCharacter3D = current_tile_3d.get_token_character(character_to_move)
	var objective_tile_3d: Tile3D = game_root.board_3d.get_tile_3d_by_location(objective_tile)
	var objective_tile_3d_available_position_marker: Marker3D = objective_tile_3d.get_first_available_position_for_token_character()
	# TODO: Change reparent process to something visual executed in _process with position interpolation following some path3D for example
	token_character_3d.reparent(objective_tile_3d_available_position_marker, false)
	action_execution_finished.emit.call_deferred()
