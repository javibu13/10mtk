extends MarginContainer
class_name PlayerInfoCharacter

var character: Enums.Character

@export var type: Enums.PlayerInfoCharacterType = Enums.PlayerInfoCharacterType.OBJECTIVE
@export var is_unknown: bool = true

@onready var objective_texture_rect: TextureRect = $FreePlace_Control/Type_CenterContainer/Background_TextureRect/Objective_TextureRect
@onready var player_tecture_rect: TextureRect = $FreePlace_Control/Type_CenterContainer/Background_TextureRect/Player_TectureRect
@onready var background_texture_rect: TextureRect = $FreePlace_Control/Character_CenterContainer/Background_TextureRect
@onready var unknown_image_texture_rect: TextureRect = $FreePlace_Control/Character_CenterContainer/Background_TextureRect/UnknownImage_TextureRect
@onready var character_image_texture_rect: TextureRect = $FreePlace_Control/Character_CenterContainer/Background_TextureRect/CharacterImage_TextureRect
@onready var x_texture_rect: TextureRect = $FreePlace_Control/Character_CenterContainer/X_TextureRect
@onready var arrested_texture_rect: TextureRect = $FreePlace_Control/Character_CenterContainer/Background_TextureRect/Arrested_TextureRect
@onready var result_position_label: RichTextLabel = $FreePlace_Control/Type_CenterContainer/Background_TextureRect/ResultPosition_RichTextLabel
@onready var character_selection_texture_button: TextureButton = $FreePlace_Control/Character_CenterContainer/CharacterSelection_TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if type == Enums.PlayerInfoCharacterType.ASSASSIN:
		objective_texture_rect.hide()
	else:
		player_tecture_rect.hide()
	if is_unknown:
		character_image_texture_rect.hide()
		background_texture_rect.self_modulate = Color("b3a392ff")
	else:
		unknown_image_texture_rect.hide()
	x_texture_rect.hide()
	arrested_texture_rect.hide()
	result_position_label.hide()


func set_new_character(new_character: Enums.Character, new_image: Texture2D, new_self_modulate_color: Color) -> void:
	character = new_character
	character_image_texture_rect.texture = new_image
	background_texture_rect.self_modulate = new_self_modulate_color
	# TODO: Request new position for the character_image_texture_rect to center it properly
	unknown_image_texture_rect.hide()
	character_image_texture_rect.show()


func set_character_as_dead() -> void:
	x_texture_rect.show()
	background_texture_rect.modulate = Color("6b6b6b")


func set_character_as_arrested() -> void:
	arrested_texture_rect.show()
	background_texture_rect.modulate = Color("aaaaaaff")


func set_character_for_results_view(podium_order: int = 0) -> void:
	objective_texture_rect.hide()
	player_tecture_rect.hide()
	arrested_texture_rect.hide()
	x_texture_rect.hide()
	result_position_label.text = str(podium_order, "º") if podium_order > 0 else "?"
	result_position_label.show()


func set_character_info_of_local_player(game_root: GameRootNode) -> void:
	character_selection_texture_button.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED
	character_selection_texture_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	character_selection_texture_button.pressed.connect(_character_info_selected.bind(game_root))


func _character_info_selected(game_root: GameRootNode) -> void:
	if x_texture_rect.visible or arrested_texture_rect.visible:
		return
	game_root.character_info_selected.emit(character)
