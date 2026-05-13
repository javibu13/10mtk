extends Control
class_name PlayerInfoResult

const POINTS_SAFE_AND_SOUND := 20
const POINTS_KILLED_OBJECTIVE := 10
const POINTS_ARRESTED_PLAYER := 10
const POINTS_KILLED_PLAYER := 30
const POINTS_KILLED_INNOCENT: int = -10
const POINTS_KILLED_POLICE: int = -1337

var player: Player
var points_items: Array[PointsItem] = []
var points_item_scene: Resource
var total_score: int = 0
var winner: bool = false
var podium_order: int

@onready var total_points_number_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/TotalPointsNumber_RichTextLabel
@onready var character_info_control: PlayerInfoCharacter = $PanelContainer/MarginContainer/VBoxContainer/Header_HBoxContainer/CharacterInfo_MarginControl
@onready var player_user_name_rich_text_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/Header_HBoxContainer/VBoxContainer/PlayerUserName_RichTextLabel
@onready var player_user_name_and_winner_h_separator: HSeparator = $PanelContainer/MarginContainer/VBoxContainer/Header_HBoxContainer/VBoxContainer/PlayerUserNameAndWinner_HSeparator
@onready var winner_rich_text_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/Header_HBoxContainer/VBoxContainer/Winner_RichTextLabel
@onready var points_items_v_box_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer2/PanelContainer/ScrollContainer/PointsItems_VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func set_up(player_assigned: Player, points_item_resource: Resource):
	player = player_assigned
	points_item_scene = points_item_resource
	player_user_name_rich_text_label.text = player.user_name
	character_info_control.set_new_character(player.assassin, load(Enums.CHARACTER_INFO[player.assassin].image_path), Color(Enums.CHARACTER_INFO[player.assassin].color))
	character_info_control.set_character_for_results_view()


func set_winner() -> void:
	winner = true
	player_user_name_and_winner_h_separator.custom_minimum_size.y -= winner_rich_text_label.custom_minimum_size.y
	winner_rich_text_label.show()


func set_podium_order(new_podium_order: int) -> void:
	podium_order = new_podium_order
	character_info_control.set_character_for_results_view(podium_order)


func generate_score():
	if player.status == Enums.PlayerStatus.LIVE:
		# Add points for staying alive at the end of the match
		var points_item: PointsItem = points_item_scene.instantiate()
		points_items.append(points_item)
		points_items_v_box_container.add_child(points_item)
		points_item.set_up(POINTS_SAFE_AND_SOUND, "Safe and sound")
		total_score += POINTS_SAFE_AND_SOUND
	for character_killed in player.kills:
		if character_killed <= Enums.Character.POLICE_1:
			# Add points (negatives) for killing a police
			var points_item: PointsItem = points_item_scene.instantiate()
			points_items.append(points_item)
			points_items_v_box_container.add_child(points_item)
			points_item.set_up(POINTS_KILLED_POLICE, "Police killed")
			total_score += POINTS_KILLED_POLICE
		elif character_killed in player.objectives:
			# Add points for killing an objective
			var points_item: PointsItem = points_item_scene.instantiate()
			points_items.append(points_item)
			points_items_v_box_container.add_child(points_item)
			points_item.set_up(POINTS_KILLED_OBJECTIVE, "Objective killed")
			total_score += POINTS_KILLED_OBJECTIVE
		elif ClientGlobalData.public_game.players.any(func(player_any: Player): return character_killed == player_any.assassin):
			# Add points for killing an enemy assassin (player)
			var player_killed: Player = ClientGlobalData.public_game.players[ClientGlobalData.public_game.players.find_custom(func(player_find: Player): return character_killed == player_find.assassin)]
			var points_item: PointsItem = points_item_scene.instantiate()
			points_items.append(points_item)
			points_items_v_box_container.add_child(points_item)
			points_item.set_up(POINTS_KILLED_PLAYER, "Other player's assassin killed (" + player_killed.user_name + ")")
			total_score += POINTS_KILLED_PLAYER
		else: 
			# Add points (negative) for killing an innocent
			var points_item: PointsItem = points_item_scene.instantiate()
			points_items.append(points_item)
			points_items_v_box_container.add_child(points_item)
			points_item.set_up(POINTS_KILLED_INNOCENT, "Innocent victim killed")
			total_score += POINTS_KILLED_INNOCENT
	for character_arrested in player.arrests:
		# Add points for arresting an assassin (player)
		var points_item: PointsItem = points_item_scene.instantiate()
		points_items.append(points_item)
		points_items_v_box_container.add_child(points_item)
		points_item.set_up(POINTS_ARRESTED_PLAYER, "Other player's assassin arrested")
		total_score += POINTS_ARRESTED_PLAYER
	total_points_number_label.text = str(total_score)
