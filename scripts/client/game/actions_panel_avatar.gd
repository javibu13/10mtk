extends Control
class_name ActionsPanelAvatar


@onready var background_texture_rect: TextureRect = $Background_TextureRect


func set_character(character: Enums.Character) -> void:
	for character_texture_rect: TextureRect in background_texture_rect.get_children():
		if int(character_texture_rect.name.split("_")[0]) == character:
			character_texture_rect.show()
			background_texture_rect.self_modulate = Color(Enums.CHARACTER_INFO[character].color)
		else:
			character_texture_rect.hide()
