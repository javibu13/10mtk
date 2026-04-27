extends Node3D
class_name TokenCharacter3D

@export var character: Enums.Character

@onready var outline: MeshInstance3D = $TokenCharacterBaseGeo/Cylinder/Outline
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func initial_set_up(new_character: Enums.Character, new_position: Vector3):
	position = new_position
	rotation_degrees.y = randf_range(0.0, 180.0)
	character = new_character
	var character_scene: Resource = load(str("res://scenes/game/characters/", character, "_character.tscn"))
	var new_character_scene = character_scene.instantiate()
	add_child(new_character_scene)


func get_parent_tile() -> Tile3D:
	var parent = get_parent()
	if parent is Tile3D:
		return parent
	else:
		return null


func select() -> void:
	outline.show()
	animation_player.play("outline_idle")


func deselect() -> void:
	outline.hide()
	animation_player.play("RESET")
