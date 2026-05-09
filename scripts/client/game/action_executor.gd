extends Node3D
class_name ActionExecutor

signal action_execution_finished
signal continue_kill_action

var current_action_type: Enums.Action = Enums.Action.NONE
var characters_to_move: Array[Dictionary] = []
var current_character_movement: Variant
var current_police_spawning: Variant

@onready var game_root: GameRootNode = $".."
@onready var movement_path_3d: Path3D = $"../Movement_Path3D"
@onready var movement_path_follow_3d: PathFollow3D = $"../Movement_Path3D/PathFollow3D"
@onready var movement_path_3d_animation_player: AnimationPlayer = $"../Movement_Path3D/MovementPath3D_AnimationPlayer"
@onready var police_spawn_path_3d: Path3D = $"../PoliceSpawn_Path3D"
@onready var police_spawn_path_follow_3d: PathFollow3D = $"../PoliceSpawn_Path3D/PoliceSpawn_PathFollow3D"
@onready var police_spawn_path_3d_animation_player: AnimationPlayer = $"../PoliceSpawn_Path3D/PoliceSpawnPath3D_AnimationPlayer"


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
	current_action_type = Enums.Action.MOVE
	var current_tile_3d: Tile3D = game_root.board_3d.get_tile3d_of_character(character_to_move)
	var token_character_3d: TokenCharacter3D = current_tile_3d.get_token_character(character_to_move)
	var objective_tile_3d: Tile3D = game_root.board_3d.get_tile_3d_by_location(objective_tile)
	var objective_tile_3d_available_position_marker: Marker3D = objective_tile_3d.get_first_available_position_for_token_character()
	characters_to_move.append({
		"token_character_3d": token_character_3d,
		"objective_marker_3d": objective_tile_3d_available_position_marker
	})
	move_characters()
	#token_character_3d.reparent(objective_tile_3d_available_position_marker, false)
	#action_execution_finished.emit.call_deferred()


func set_up_kill_action_process(character_killed: Enums.Character) -> void:
	current_action_type = Enums.Action.KILL
	# Remove character from board
	var tile_3d_kill: Tile3D = game_root.board_3d.get_tile3d_of_character(character_killed)
	tile_3d_kill.remove_token_character_3d(character_killed)
	# Check if the player has been revealed as any player's assassin or objective
	for player in ClientGlobalData.public_game.players:
		if player.assassin == character_killed or character_killed in player.objectives:
			var player_info_panel: PlayerInfoPanel = game_root.hud_control.get_player_info_panel_by_player_index(player.index)
			player_info_panel.reveal_character(character_killed, Enums.PlayerStatus.DEAD)
			break
	# Move other characters in the tile where the kill took place to the tiles where server moved them
	for token_character_3d in tile_3d_kill.get_token_characters():
		if token_character_3d.is_queued_for_deletion():
			continue
		# Get Tile of the character at the board sent by server
		var objective_tile: Tile = ClientGlobalData.public_game.board.get_tile_of_character(token_character_3d.character)
		var objective_tile_3d: Tile3D = game_root.board_3d.get_tile_3d_by_location(objective_tile.location)
		var objective_tile_3d_available_position_marker: Marker3D = objective_tile_3d.get_first_available_position_for_token_character()
		# Move character to the Tile3D equal to Tile that server said
		characters_to_move.append({
			"token_character_3d": token_character_3d,
			"objective_marker_3d": objective_tile_3d_available_position_marker
		})
	if characters_to_move.size() > 0:
		move_characters()
		await continue_kill_action
	# Add or move police
	SoundManager.instance_and_play_sound(null, SoundManager.police_siren_sfx)
	var tile_kill: Tile = ClientGlobalData.public_game.board.get_tile_from_location(tile_3d_kill.position_in_board)
	# # Check if the police placed by server has been placed before in board
	var police_character: Enums.Character = tile_kill.polices.keys()[0]
	var tile_3d_of_police = game_root.board_3d.get_tile3d_of_character(police_character)
	if tile_3d_of_police:
		# Police has already exist in board. Only has to be moved
		var police_token_character_3d := tile_3d_of_police.get_token_character(police_character)
		characters_to_move.append({
			"token_character_3d": police_token_character_3d,
			"objective_marker_3d": tile_3d_kill.get_first_available_position_for_token_character()
		})
		move_characters()
	else:
		# Police not found in board. It has to be created
		spawn_police(police_character, tile_kill) # tile_3d_of_police.get_first_available_position_for_token_character()
	await continue_kill_action
	action_execution_finished.emit.call_deferred()


func set_up_ask_action_process(character_ask: Enums.Character, player_index_asked: int) -> void:
	current_action_type = Enums.Action.ASK
	# Check if the player's assassins has been discovered and it ir equal to character_ask
	if ClientGlobalData.public_game.players[player_index_asked].assassin == character_ask:
		var player_info_panel: PlayerInfoPanel = game_root.hud_control.get_player_info_panel_by_player_index(player_index_asked)
		player_info_panel.reveal_character(character_ask, Enums.PlayerStatus.ARRESTED)
		var arrest_tile_3d: Tile3D = game_root.board_3d.get_tile3d_of_character(character_ask)
		arrest_tile_3d.remove_token_character_3d(character_ask)
	action_execution_finished.emit.call_deferred()


func move_characters() -> void:
	current_character_movement = characters_to_move.pop_at(0)
	if current_character_movement:
		movement_path_3d.curve.set_point_position(0, current_character_movement.token_character_3d.global_position)
		movement_path_3d.curve.set_point_position(1, current_character_movement.token_character_3d.global_position + Vector3(0, 0.2, 0))
		movement_path_3d.curve.set_point_position(2, current_character_movement.objective_marker_3d.global_position + Vector3(0, 0.2, 0))
		movement_path_3d.curve.set_point_position(3, current_character_movement.objective_marker_3d.global_position)
		current_character_movement.token_character_3d.reparent(movement_path_follow_3d, false)
		movement_path_3d_animation_player.play("move")
		SoundManager.instance_and_play_sound(null, SoundManager.character_move_sfx, -2.0, randf_range(0.9, 1.2))
	elif current_action_type == Enums.Action.MOVE:
		action_execution_finished.emit.call_deferred()
	elif current_action_type == Enums.Action.KILL:
		continue_kill_action.emit()


func move_character_end() -> void:
	current_character_movement.token_character_3d.reparent(current_character_movement.objective_marker_3d, false)
	movement_path_3d_animation_player.stop()
	movement_path_follow_3d.progress_ratio = 0
	move_characters()


func spawn_police(police_character: Enums.Character, tile_kill: Tile) -> void:
	var tile_kill_3d: Tile3D = game_root.board_3d.get_tile_3d_by_location(tile_kill.location)
	var new_token_character_police: TokenCharacter3D = game_root.board_3d.token_character_resource.instantiate()
	police_spawn_path_follow_3d.add_child(new_token_character_police)
	new_token_character_police.initial_set_up(police_character, Vector3.ZERO)
	current_police_spawning = {
		"token_character_3d": new_token_character_police,
		"objective_marker_3d": tile_kill_3d.get_first_available_position_for_token_character()
	}
	police_spawn_path_3d.global_position = current_police_spawning.objective_marker_3d.global_position
	police_spawn_path_3d_animation_player.play("spawn")


func spawn_police_end() -> void:
	current_police_spawning.token_character_3d.reparent(current_police_spawning.objective_marker_3d, false)
	police_spawn_path_3d_animation_player.stop()
	police_spawn_path_follow_3d.progress_ratio = 0
	continue_kill_action.emit()
