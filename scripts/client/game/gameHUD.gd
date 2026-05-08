extends Control
class_name GameHUD

var player_info_panel_containers_active: Array[PlayerInfoPanel]
#var characters_texture2d: Dictionary[int, Resource] = {}

@export var game_root: GameRootNode
@export var main_player_panel_container: PlayerInfoPanel
@export var left_player_panel_container: PlayerInfoPanel
@export var top_player_panel_container: PlayerInfoPanel
@export var right_player_panel_container: PlayerInfoPanel


#func _ready() -> void:
	#for character_id in Enums.CHARACTER_INFO.keys():
		#characters_texture2d[character_id] = load(Enums.CHARACTER_INFO[character_id].image_path)


func set_up_player_info_panels(local_client_id: int, players: Array[Player]) -> void:
	var local_player_index: int = players.find_custom(func(player: Player): return player.client_id == local_client_id)
	var players_num: int = players.size()
	main_player_panel_container.show()
	self.show()
	player_info_panel_containers_active.append(main_player_panel_container)
	match players_num:
		# Append order is important for player index order
		2:
			player_info_panel_containers_active.append(top_player_panel_container)
		3:
			player_info_panel_containers_active.append(left_player_panel_container)
			player_info_panel_containers_active.append(right_player_panel_container)
		4:
			player_info_panel_containers_active.append(left_player_panel_container)
			player_info_panel_containers_active.append(top_player_panel_container)
			player_info_panel_containers_active.append(right_player_panel_container)
	var index_assign: int = local_player_index
	for player_info_panel_container in player_info_panel_containers_active:
		player_info_panel_container.show()
		player_info_panel_container.player_index = index_assign
		player_info_panel_container.set_user_name(players[index_assign].user_name)
		player_info_panel_container.set_timer_hidden()
		index_assign += 1
		if index_assign == players_num:
			index_assign = 0
	main_player_panel_container.player_info_assassin.set_new_character(players[local_player_index].assassin, load(Enums.CHARACTER_INFO[players[local_player_index].assassin].image_path), Enums.CHARACTER_INFO[players[local_player_index].assassin].color)
	for index in range(3):
		main_player_panel_container.player_info_objectives[index].set_new_character(players[local_player_index].objectives[index], load(Enums.CHARACTER_INFO[players[local_player_index].objectives[index]].image_path), Enums.CHARACTER_INFO[players[local_player_index].objectives[index]].color)
	main_player_panel_container.set_up_all_characters_info_as_local(game_root)

func get_player_info_panel_by_player_index(player_index: int) -> PlayerInfoPanel:
	var player_info_panel_containers_active_of_player_index = player_info_panel_containers_active.find_custom(func(player_info_panel: PlayerInfoPanel): return player_info_panel.player_index == player_index)
	return player_info_panel_containers_active[player_info_panel_containers_active_of_player_index]
