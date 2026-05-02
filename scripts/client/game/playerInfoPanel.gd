extends PanelContainer
class_name PlayerInfoPanel

var player_index: int = -1

@export var type: Enums.PlayerInfoPanelType
@export var player_info_assassin: PlayerInfoCharacter
@export var player_info_objectives: Array[PlayerInfoCharacter]
@export var user_name_text: RichTextLabel
@export var timer_control: TimerControl


func _ready() -> void:
	# Start hidden because it will be shown if it is needed depending on number of players
	self.hide()
	timer_control.set_hidden()


func set_user_name(new_user_name: String) -> void:
	if user_name_text:
		user_name_text.text = new_user_name


func set_timer_hidden() -> void:
	timer_control.set_hidden()


func show_and_start_timer(new_time: int, new_action_number: int) -> void:
	timer_control.set_action_number(new_action_number)
	timer_control.set_and_start_timer(new_time)
	timer_control.show_anim()


func hide_timer() -> void:
	timer_control.hide_anim()


func reveal_character(character: Enums.Character, status: Enums.PlayerStatus = Enums.PlayerStatus.LIVE) -> void:
	if ClientGlobalData.public_game.players[player_index].assassin == character:
		player_info_assassin.set_new_character(character, load(Enums.CHARACTER_INFO[character].image_path), Enums.CHARACTER_INFO[character].color)
		if status == Enums.PlayerStatus.DEAD:
			player_info_assassin.set_character_as_dead()
		elif status == Enums.PlayerStatus.ARRESTED:
			player_info_assassin.set_character_as_arrested()
	elif character in ClientGlobalData.public_game.players[player_index].objectives:
		var objective_index = ClientGlobalData.public_game.players[player_index].objectives.find(character)
		player_info_objectives[objective_index].set_new_character(character, load(Enums.CHARACTER_INFO[character].image_path), Enums.CHARACTER_INFO[character].color)
		if status == Enums.PlayerStatus.DEAD:
			player_info_objectives[objective_index].set_character_as_dead()
		elif status == Enums.PlayerStatus.ARRESTED:
			player_info_objectives[objective_index].set_character_as_arrested()
