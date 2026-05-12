extends Node3D
class_name TokenCharacter3D

@export_range(0.0, 1.0) var opacity: float = 1.0:
	set(value):
		opacity = value
		_update_opacity(self, opacity)
@export var character: Enums.Character

@onready var outline: MeshInstance3D = $TokenCharacterBaseGeo/Cylinder/Outline
@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func initial_set_up(new_character: Enums.Character, new_position: Vector3):
	position = new_position
	rotation_degrees.y = randf_range(0.0, 180.0)
	character = new_character
	var character_scene: Resource = load(str("res://scenes/game/characters/", character, "_character.tscn"))
	var new_character_scene = character_scene.instantiate()
	add_child(new_character_scene)


func get_parent_tile() -> Tile3D:
	var parent = null
	for index in range(0, 5):
		parent = parent.get_parent() if parent else get_parent()
		if parent is Tile3D:
			break
	return parent


func select() -> void:
	outline.show()
	animation_player.play("outline_idle")


func deselect() -> void:
	outline.hide()
	animation_player.play("RESET")


func _update_opacity(node: Node, alpha: float):
	for child in node.get_children(true):
		# Check if the child is a mesh
		if child is GeometryInstance3D:
			# Creates a unique copy of the material to keep the original safe from changes to avoid affecting other meshes
			var material_override: Material = child.material_override
			if material_override is StandardMaterial3D:
				var new_material_override := material_override.duplicate_deep()
				new_material_override.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				new_material_override.albedo_color.a = alpha
				child.material_override = new_material_override
			var material_overlay: Material = child.material_overlay
			if material_overlay is StandardMaterial3D:
				var new_material_overlay := material_overlay.duplicate_deep()
				new_material_overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				new_material_overlay.albedo_color.a = alpha
				child.material_overlay = new_material_overlay
		# Recursive
		_update_opacity(child, alpha)


func start_die_anim() -> void:
	animation_player.play("die")
	SoundManager.instance_and_play_sound(null, SoundManager.dead_sfx, 0.0, randf_range(1.0, 1.4))


func die_anim_end() -> void:
	var action_executor: ActionExecutor = get_tree().root.find_child("ActionExecutor", true, false)
	action_executor.continue_kill_action.emit()
