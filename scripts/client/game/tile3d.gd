extends Node3D

class_name Tile3D

@export var position_in_board: Vector2i = Vector2i.ZERO
@export var is_sniper : bool = false
@export var sniper_material : StandardMaterial3D
@export var tile_base : Node3D
@export var tile_selector : Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


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
	tile_base.get_child(0).material_override = sniper_material


func select() -> void:
	print('Select: ' + self.name)
	tile_selector.find_child('AnimationPlayer').play('idle')
	tile_selector.visible = true


func deselect() -> void:
	print('Deselect: ' + self.name)
	tile_selector.visible = false
	tile_selector.find_child('AnimationPlayer').stop()
