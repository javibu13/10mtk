extends Node3D
class_name GameRootNode

signal public_data_received
signal tile_resource_loaded
signal token_character_resource_loaded
signal player_info_panels_loaded
signal board_built
signal set_up_ended
signal turn_timeout
signal token_character_selected(token_character: TokenCharacter3D)
signal actions_panel_closed
signal action_editing_started(action: Enums.Action)
signal action_editing_canceled
signal action_confirmed(action: Enums.Action, info)


const TILE_SCENE_PATH = "res://scenes/game/Tile.tscn"
const TOKEN_CHARACTER_SCENE_PATH = "res://scenes/game/TokenCharacterBase.tscn"


@export var actions_panel: ActionsPanel


var tile_resource: Resource
var token_character_resource: Resource


@onready var board_3d:  = $Board3D
@onready var loading_screen_control: Control = $CanvasLayer/LoadingScreen_Control
@onready var hud_control: GameHUD = $CanvasLayer/HUD_Control




func _ready() -> void:
	loading_screen_control.show()
	set_up_ended.connect(_set_up_ended)
	# Check if ClientGlobalData.public_game has received the game_info to set up the beginning of the match (board, characters, ui...)
	if ClientGlobalData.public_game != null:
		# Launch game set up
		_public_data_received()
	else:
		GameManager.initial_info_received.connect(_public_data_received)
	# Load tile scene
	ResourceLoader.load_threaded_request(TILE_SCENE_PATH)
	ResourceLoader.load_threaded_request(TOKEN_CHARACTER_SCENE_PATH)
	GameManager.new_turn_received.connect(_new_turn_process)
	turn_timeout.connect(_turn_timeout)
	token_character_selected.connect(_token_charecter_selected)


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if not tile_resource:
		tile_resource = _check_load_threaded_request(TILE_SCENE_PATH, tile_resource_loaded)
	if not token_character_resource:
		token_character_resource = _check_load_threaded_request(TOKEN_CHARACTER_SCENE_PATH, token_character_resource_loaded)
	if tile_resource and token_character_resource and ClientGlobalData.public_game:
		hud_control.set_up_player_info_panels(multiplayer.get_unique_id(), ClientGlobalData.public_game.players)
		player_info_panels_loaded.emit()
		board_3d.tile_resource = tile_resource
		board_3d.token_character_resource = token_character_resource
		board_3d.generate_board(ClientGlobalData.public_game.board)
		board_built.emit()
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


func _set_up_ended() -> void:
	GameManager.server_notify_client_ready_to_start_match.rpc_id(1, ClientGlobalData.public_game.game_id)


func _new_turn_process() -> void:
	if ClientGlobalData.public_game.turn.previous:
		var previous_turn: TurnPrev = ClientGlobalData.public_game.turn.previous
		var player_info_panel_index_for_prev_turn = hud_control.player_info_panel_containers_active.find_custom(func(player_info_panel: PlayerInfoPanel): return player_info_panel.player_index == previous_turn.player_index)
		hud_control.player_info_panel_containers_active[player_info_panel_index_for_prev_turn].hide_timer()
		# TODO: Show and update last action
		pass
	else:
		# First turn received
		loading_screen_control.hide()
	var new_turn = ClientGlobalData.public_game.turn
	var player_info_panel_index_for_new_turn = hud_control.player_info_panel_containers_active.find_custom(func(player_info_panel: PlayerInfoPanel): return player_info_panel.player_index == new_turn.player_index)
	hud_control.player_info_panel_containers_active[player_info_panel_index_for_new_turn].show_and_start_timer(new_turn.time, new_turn.action_number)
	# Check if the player_panel_index is the first in the array. This means that local player has to play the turn
	if player_info_panel_index_for_new_turn == 0:
		# Local player turn
		ClientGlobalData.is_local_player_turn = true
		# TODO: CONTINUE
	else:
		# Remote player turn
		ClientGlobalData.is_local_player_turn = false


func _turn_timeout() -> void:
	var current_turn = ClientGlobalData.public_game.turn
	var player_info_panel_index_for_new_turn = hud_control.player_info_panel_containers_active.find_custom(func(player_info_panel: PlayerInfoPanel): return player_info_panel.player_index == current_turn.player_index)
	# Check if the player_panel_index is the first in the array. This means that local player had to play the turn
	hud_control.player_info_panel_containers_active[player_info_panel_index_for_new_turn].hide_timer()
	if player_info_panel_index_for_new_turn == 0:
		# TODO: Disable local player interaction to avoid sending 2 turn actions
		pass


func _token_charecter_selected(token_character: TokenCharacter3D) -> void:
	# Get the local player's assassin
	var local_player_index: int = ClientGlobalData.public_game.players.find_custom(func(player: Player): return player.client_id == multiplayer.get_unique_id())
	var assassin: Enums.Character = ClientGlobalData.public_game.players[local_player_index].assassin
	# Get if is possible to execute each action over the selected character
	var allow_kill_action = can_be_killed(token_character.character, assassin) if token_character.character != assassin else false
	var allow_investigate_action = can_be_investigated(token_character.character) if token_character.character != assassin else false
	actions_panel.set_up_panel(token_character.character, true, allow_kill_action, allow_investigate_action)


func can_be_killed(character_to_kill: Enums.Character, assassin: Enums.Character) -> bool:
	# Check if there are any police near
	var orthogonal_cross_of_tiles_of_assassin: Array[Tile] = ClientGlobalData.public_game.board.get_orthogonal_cross_tiles_of_character(assassin)
	if orthogonal_cross_of_tiles_of_assassin.any(func(tile: Tile): return tile.polices.keys().size() > 0):
		return false
	# Check if character_to_kill and assassin share tile
	if character_to_kill in orthogonal_cross_of_tiles_of_assassin[0].characters.keys():
		Log.pr("Allow knife kill")
		return true
	# Check if the assassin is not alone in his tile because gun and sniper need this condition
	if orthogonal_cross_of_tiles_of_assassin[0].characters.keys().size() != 1:
		return false
	# Check if character_to_kill is placed in any of the directly adjacent tiles to the assassin's tile
	var characters_in_tiles_in_cross_arround_assassin: Array[Enums.Character] = []
	for tile in orthogonal_cross_of_tiles_of_assassin:
		characters_in_tiles_in_cross_arround_assassin.append_array(tile.characters.keys())
	if character_to_kill in characters_in_tiles_in_cross_arround_assassin:
		Log.pr("Allow gun kill")
		return true
	# Check if assassin is placed in a sniper tile
	if orthogonal_cross_of_tiles_of_assassin[0].type == Enums.TileType.SNIPER:
		# Check if character_to_kill is placed any tile orthogonal to the assassin's tile
		var orthogonal_extension_of_tiles_arround_assassin: Array[Tile] = ClientGlobalData.public_game.board.get_orthogonal_cross_tiles_of_character(assassin, ClientGlobalData.public_game.board.tile_num)
		var characters_in_tiles_in_extension_arround_assassin: Array[Enums.Character] = []
		for tile in orthogonal_extension_of_tiles_arround_assassin:
			characters_in_tiles_in_extension_arround_assassin.append_array(tile.characters.keys())
		if character_to_kill in characters_in_tiles_in_extension_arround_assassin:
			Log.pr("Allow sniper kill")
			return true
	Log.pr("Kill not allow")
	return false


func can_be_investigated(character_to_investigate: Enums.Character) -> bool:
	return not ClientGlobalData.public_game.board.get_tile_of_character(character_to_investigate).polices.is_empty()
