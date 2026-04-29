extends Node3D

class_name Tile3D

@export var position_in_board: Vector2i = Vector2i.ZERO
@export var is_sniper: bool = false
@export var sniper_material_overlay: StandardMaterial3D
@export var texture_tile_base_pool: Array[Texture2D]
@export var tile_base: Node3D
@export var tile_selector: Node3D
@export var token_character_positions_to_place: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var available_tiles: Array[Texture2D] = texture_tile_base_pool.filter(func(element: Texture2D): return element != null)
	var new_material: StandardMaterial3D = tile_base.get_child(0).material_override.duplicate()
	new_material.albedo_texture = available_tiles.pick_random()
	tile_base.get_child(0).material_override = new_material


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Place the square to its 3d position
func place(newPosition : Vector2i) -> void:
	position_in_board = newPosition
	position.x = position_in_board.x
	position.z = position_in_board.y


func set_sniper() -> void:
	is_sniper = true
	tile_base.get_child(0).material_overlay = sniper_material_overlay


func select(show_selection_graphic: bool = false) -> void:
	Log.pr('Select: ' + self.name)
	if show_selection_graphic:
		tile_selector.find_child('AnimationPlayer').play('idle')
		tile_selector.visible = true


func deselect() -> void:
	Log.pr('Deselect: ' + self.name)
	tile_selector.visible = false
	tile_selector.find_child('AnimationPlayer').stop()


func create_token_character(token_character_resource: Resource, character: Enums.Character):
	var new_token_character: TokenCharacter3D = token_character_resource.instantiate()
	get_first_available_position_for_token_character().add_child(new_token_character)
	# TODO: Set random position to place the token character
	var new_position = Vector3.ZERO
	new_token_character.initial_set_up(character, new_position)


func get_token_characters() -> Array[TokenCharacter3D]:
	var token_characters: Array[TokenCharacter3D] = []
	for child in get_children():
		if child is TokenCharacter3D:
			token_characters.append(child)
	return token_characters


func get_first_available_position_for_token_character() -> Marker3D:
	var children = token_character_positions_to_place.get_children()
	var available_marker_position_index = token_character_positions_to_place.get_children().find_custom(func(marker3d: Marker3D): return true if marker3d.get_child_count() else false)
	return children[available_marker_position_index]
