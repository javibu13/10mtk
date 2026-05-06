extends Control
class_name PlayerResultControl

var player_info_result_scene := load("res://scenes/game/player_info_result.tscn")
var points_item_scene := load("res://scenes/game/points_item.tscn")
var player_info_results: Array[PlayerInfoResult] = []

@onready var player_results_h_box_container: HBoxContainer = $VBoxContainer/PlayerResults_HBoxContainer
@onready var continue_button: Button = $VBoxContainer/Continue_Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func set_up() -> void:
	continue_button.pressed.connect(_change_to_main_menu)
	for player in ClientGlobalData.public_game.players:
		var player_info_result: PlayerInfoResult = player_info_result_scene.instantiate()
		player_info_results.append(player_info_result)
		player_results_h_box_container.add_child(player_info_result)
		player_info_result.set_up(player, points_item_scene)
		player_info_result.generate_score()
	var array_player_results: Array[PlayerInfoResult] = []
	var winner_player_results: Array[PlayerInfoResult] = player_info_results.reduce(
		func(accum, player_info_result_reduce):
			if accum.size() > 0:
				if player_info_result_reduce.total_score > accum[0].total_score:
					accum.clear()
					accum.append(player_info_result_reduce)
				elif player_info_result_reduce.total_score == accum[0].total_score:
					accum.append(player_info_result_reduce)
			else:
				accum.append(player_info_result_reduce)
			return accum
			, array_player_results)
	var winner_player_result: PlayerInfoResult = null
	if winner_player_results.size() > 1:
		# RESOLVE TIE
		if winner_player_results.all(func(winner_player_result_all: PlayerInfoResult): return winner_player_result_all.player.index in ClientGlobalData.public_game.player_elimination_order):
			# All tied players have been arrested or killed, so the player who last the most wins
			for eliminated_player_index in ClientGlobalData.public_game.player_elimination_order:
				if eliminated_player_index in winner_player_results.map(func(winner_player_result_map: PlayerInfoResult): return winner_player_result_map.player.index):
					winner_player_result = winner_player_results[winner_player_results.find_custom(func(player_res: PlayerInfoResult): return player_res.player.index == eliminated_player_index)]
					break
		elif winner_player_results.any(func(winner_player_result_all: PlayerInfoResult): return winner_player_result_all.player.index in ClientGlobalData.public_game.player_elimination_order):
			var winner_player_results_alive: Array = winner_player_results.filter(func(winner_player_result_all: PlayerInfoResult): return not winner_player_result_all.player.index in ClientGlobalData.public_game.player_elimination_order)
			var winner_player_index: Array = winner_player_results_alive.map(func(winner_player_result_map: PlayerInfoResult): return winner_player_result_map.player.index)
			winner_player_result = winner_player_results[winner_player_results.find_custom(func(player_res: PlayerInfoResult): return player_res.player.index == winner_player_index.min())]
		else:
			var winner_player_index: Array = winner_player_results.map(func(winner_player_result_map: PlayerInfoResult): return winner_player_result_map.player.index)
			winner_player_result = winner_player_results[winner_player_results.find_custom(func(player_res: PlayerInfoResult): return player_res.player.index == winner_player_index.min())]
	else:
		winner_player_result = winner_player_results[0]
	winner_player_result.set_winner()
	var all_players_score_points: Array = player_info_results.map(func(player_info_result_map: PlayerInfoResult): return player_info_result_map.total_score)
	all_players_score_points.sort()
	all_players_score_points.reverse()
	for player_info_result in player_info_results:
		var player_podium_order = all_players_score_points.find(player_info_result.total_score) + 1
		if player_podium_order == 1 and not player_info_result.winner:
			player_podium_order += 1
		player_info_result.set_podium_order(player_podium_order)


# Change scene to MainMenu
func _change_to_main_menu():
	ClientGlobalData.reset_all_match_related_data()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
