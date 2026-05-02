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


func set_up_kill_action_process(character_killed: Enums.Character) -> void:
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
		# TODO: Change reparent process to something visual executed in _process with position interpolation following some path3D for example
		token_character_3d.reparent(objective_tile_3d_available_position_marker, false)
	# Add or move police
	var tile_kill: Tile = ClientGlobalData.public_game.board.get_tile_from_location(tile_3d_kill.position_in_board)
	# # Check if the police placed by server has been placed before in board
	var police_character: Enums.Character = tile_kill.polices.keys()[0]
	var tile_3d_of_police = game_root.board_3d.get_tile3d_of_character(police_character)
	if tile_3d_of_police:
		# Police has already exist in board. Only has to be moved
		var police_token_character_3d := tile_3d_of_police.get_token_character(police_character)
		# TODO: Change reparent process to something visual executed in _process with position interpolation following some path3D for example
		police_token_character_3d.reparent(tile_3d_kill.get_first_available_position_for_token_character(), false)
	else:
		# Police not found in board. It has to be created
		tile_3d_kill.create_token_character(game_root.board_3d.token_character_resource, police_character)
	action_execution_finished.emit.call_deferred()


func set_up_ask_action_process(character_ask: Enums.Character, player_index_asked: int) -> void:
	# Check if the player's assassins has been discovered and it ir equal to character_ask
	if ClientGlobalData.public_game.players[player_index_asked].assassin == character_ask:
		var player_info_panel: PlayerInfoPanel = game_root.hud_control.get_player_info_panel_by_player_index(player_index_asked)
		player_info_panel.reveal_character(character_ask, Enums.PlayerStatus.ARRESTED)
		var arrest_tile_3d: Tile3D = game_root.board_3d.get_tile3d_of_character(character_ask)
		arrest_tile_3d.remove_token_character_3d(character_ask)
	action_execution_finished.emit.call_deferred()
