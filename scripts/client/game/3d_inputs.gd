extends Camera3D

class_name CameraInputs3D

# Selection variables
var allow_select := false
var is_pressed := false
var tile_selected: Tile3D = null
var token_character_selected: TokenCharacter3D = null
# Moving camera variables
var is_moving := false
var elapsed_moving_time := 0.0
var move_initial_position: Vector3
var move_final_position: Vector3
@export var move_duration := 0.2
@export var pivot_position: Node3D
# Rotation camera variables
@export var pivot_rotation: Node3D
@export var CAMERA_MOVE_SENSITIVITY := 2.0	#TODO: Modify this value in user's settings
const CAMERA_MOVE_THRESHOLD := 10.0
var is_camera_rotating := false
var prev_mouse_position := Vector2.ZERO
var new_mouse_position := Vector2.ZERO
var is_first_frame_rotating := true
var rotate_dead_zone := Vector2.ZERO
var allow_rotation := false
var prev_drag_motion_event: InputEventFromWindow = null
# Zoom variables
var is_zoom := false
var second_touch = null # Vector2
var prev_touch_distance := -1.0

@export var debug_label: Label
@export var game_root: GameRootNode


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _unhandled_input(event: InputEvent) -> void:
	if !is_moving:
		if ((event is InputEventMouseButton and event.button_index == 1) or (event is InputEventScreenTouch and event.index == 0)) and event.is_pressed():
			allow_select = true
			is_pressed = true
			is_camera_rotating = false
		elif ((event is InputEventMouseButton and event.button_index == 1) or (event is InputEventScreenTouch and event.index == 0)) and allow_select and !event.is_pressed():
			#print('Shoot ray to select')
			#debug_label.text = 'Shoot ray to select'
			shoot_ray(event.position)
			is_pressed = false
			allow_select = false
			is_camera_rotating = false
			allow_rotation = false
			rotate_dead_zone = Vector2.ZERO
			prev_drag_motion_event = null
		elif (event is InputEventMouseMotion or event is InputEventScreenDrag) and is_pressed:
			if (event is InputEventMouseMotion or (event is InputEventScreenDrag and event.index == 0)) and !is_zoom:
				if !allow_rotation:
					rotate_dead_zone += (event.position - prev_drag_motion_event.position) if prev_drag_motion_event else Vector2.ZERO
					prev_drag_motion_event = event
				if rotate_dead_zone.length() > CAMERA_MOVE_THRESHOLD:
					allow_select = false
					allow_rotation = true
					#Rotate Camera
					new_mouse_position = event.position
					is_camera_rotating = true
			elif event is InputEventScreenDrag and event.index == 1:
				is_zoom = true
				second_touch = event.position
				allow_rotation = false
			elif event is InputEventScreenDrag and event.index == 0 and is_zoom:
				new_mouse_position = event.position
				allow_rotation = false
		elif (event is InputEventMouseButton and (event.button_index == 4 or event.button_index == 5) and event.is_pressed() and !allow_select and !is_pressed and !is_camera_rotating):
			# TODO: Continue here: Difference between (event.button_index == 4 or event.button_index == 5) to add or substract zoom and increase forced touchDistance.
			if event.button_index == 4:
				new_mouse_position = Vector2.DOWN*30
				prev_touch_distance = 1.0
			else:	# event.button_index == 5
				new_mouse_position = Vector2.UP
				prev_touch_distance = 30.0
			is_zoom = true
			second_touch = Vector2.ZERO
		elif !event.is_pressed():
			if ((event is InputEventScreenTouch or event is InputEventScreenDrag) and event.index == 0) or (event is InputEventMouseButton and event.button_index == 1):
				is_pressed = false
				is_camera_rotating = false
				is_first_frame_rotating = true
				allow_rotation = false
				rotate_dead_zone = Vector2.ZERO
				prev_drag_motion_event = null
				new_mouse_position = Vector2.ZERO
				is_zoom = false
				second_touch = null
				prev_touch_distance = -1.0
			elif ((event is InputEventScreenTouch or event is InputEventScreenDrag) and event.index == 1) or (event is InputEventMouseButton and (event.button_index == 4 or event.button_index == 5)):
				if (event is InputEventMouseButton and (event.button_index == 4 or event.button_index == 5)): await get_tree().create_timer(0.1).timeout
				#print("End Zoom")
				is_zoom = false
				second_touch = null
				prev_touch_distance = -1.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# debug_label.text = str(pivot_rotation.rotation_degrees)
	if is_moving:
		var move_progress = clampf(elapsed_moving_time / move_duration, 0.0, 1.0)
		var current_position = move_initial_position.lerp(move_final_position, move_progress)
		pivot_position.global_transform.origin = current_position
		elapsed_moving_time += delta
		if move_progress >= 1.0:
			is_moving = false
			elapsed_moving_time = 0.0
	elif is_camera_rotating:
		if !is_first_frame_rotating:
			var diff_mouse_position = new_mouse_position - prev_mouse_position
			pivot_rotation.rotation_degrees.x -= diff_mouse_position.y/CAMERA_MOVE_SENSITIVITY
			pivot_rotation.rotation_degrees.x = clampf(pivot_rotation.rotation_degrees.x, 0.0, 85.0)
			pivot_rotation.rotation_degrees.y -= diff_mouse_position.x/CAMERA_MOVE_SENSITIVITY
			is_camera_rotating = false
		else:
			is_first_frame_rotating = false
		prev_mouse_position = new_mouse_position
	elif is_zoom and new_mouse_position != Vector2.ZERO and second_touch != null:
		#print("ZOOOM PROCESS")
		if prev_touch_distance > 0.0:
			var current_distance = new_mouse_position.distance_to(second_touch)
			var touch_distance_increment = current_distance-prev_touch_distance
			#debug_label.text = "new_mouse_position:"+str(new_mouse_position) + " | second_touch: "+str(second_touch) + " | current_distance: "+str(current_distance) + " | prev_touch_distance: "+str(prev_touch_distance) + " | touch_distance_increment" + str(touch_distance_increment) + "\n" + debug_label.text
			self.position.y -= touch_distance_increment/100
			self.position.y = clampf(self.position.y, 1.0, 5.0)
			prev_touch_distance = current_distance
		else:
			var current_distance = new_mouse_position.distance_to(second_touch)
			prev_touch_distance = current_distance
	elif second_touch == null:
		prev_touch_distance = 0.0


func shoot_ray(eventPosition : Vector2) -> void:
	var ray_length = 1000
	var from = project_ray_origin(eventPosition)
	var to = from + project_ray_normal(eventPosition) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)
	if 'collider' in raycast_result:
		var col_parent = raycast_result.collider.get_parent()
		#print(col_parent)
		if col_parent is Tile3D:
			select_tile(col_parent)
		elif col_parent is TokenCharacter3D:
			select_token_character(col_parent)
	else:
		deselect_token_character()


func select_tile(tile: Tile3D, show_selection_graphic: bool = false) -> void:
	if tile_selected:
		tile_selected.deselect()
	tile_selected = tile
	tile_selected.select(show_selection_graphic)
	set_up_move_to_square(tile_selected)


func set_up_move_to_square(tile: Tile3D) -> void:
	move_initial_position = pivot_position.position
	move_final_position = Vector3(tile.position_in_board.x, pivot_position.position.y, tile.position_in_board.y)
	is_moving = true


func select_token_character(token_character: TokenCharacter3D):
	if ClientGlobalData.is_local_player_turn:
		if token_character_selected:
			token_character_selected.deselect()
		token_character_selected = token_character
		token_character_selected.select()
		game_root.token_character_selected.emit(token_character)
	select_tile(token_character.get_parent_tile())


func deselect_token_character():
	if token_character_selected:
		token_character_selected.deselect()
		token_character_selected = null
