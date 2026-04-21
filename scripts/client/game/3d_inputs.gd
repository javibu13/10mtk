extends Camera3D

class_name CameraInputs3D

# Selection variables
var allowSelect := false
var isPressed := false
var squareSelected : Tile3D = null
# Moving camera variables
var isMoving := false
var elapsedMovingTime := 0.0
var moveInitialPosition : Vector3
var moveFinalPosition : Vector3
@export var moveDuration := 0.2
@export var pivotPosition : Node3D
# Rotation camera variables
@export var pivotRotation : Node3D
@export var CAMERA_MOVE_SENSITIVITY := 2.0	#TODO: Modify this value in user's settings
const CAMERA_MOVE_THRESHOLD := 10.0
var isCameraRotating := false
var prevMousePosition := Vector2.ZERO
var newMousePosition := Vector2.ZERO
var isFirstFrameRotating := true
var rotateDeadZone := Vector2.ZERO
var allowRotation := false
var prevDragMotionEvent : InputEventFromWindow = null
# Zoom variables
var isZoom := false
var secondTouch = null # Vector2
var prevTouchDistance := -1.0

@export var debugLabel : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if !isMoving:
		if ((event is InputEventMouseButton and event.button_index == 1) or (event is InputEventScreenTouch and event.index == 0)) and event.is_pressed():
			allowSelect = true
			isPressed = true
			isCameraRotating = false
		elif ((event is InputEventMouseButton and event.button_index == 1) or (event is InputEventScreenTouch and event.index == 0)) and allowSelect and !event.is_pressed():
			print('Shoot ray to select')
			#debugLabel.text = 'Shoot ray to select'
			shootRay(event.position)
			isPressed = false
			allowSelect = false
			isCameraRotating = false
			allowRotation = false
			rotateDeadZone = Vector2.ZERO
			prevDragMotionEvent = null
		elif (event is InputEventMouseMotion or event is InputEventScreenDrag) and isPressed:
			if (event is InputEventMouseMotion or (event is InputEventScreenDrag and event.index == 0)) and !isZoom:
				if !allowRotation:
					rotateDeadZone += (event.position - prevDragMotionEvent.position) if prevDragMotionEvent else Vector2.ZERO
					prevDragMotionEvent = event
				if rotateDeadZone.length() > CAMERA_MOVE_THRESHOLD:
					allowSelect = false
					allowRotation = true
					#Rotate Camera
					newMousePosition = event.position
					isCameraRotating = true
			elif event is InputEventScreenDrag and event.index == 1:
				isZoom = true
				secondTouch = event.position
				allowRotation = false
			elif event is InputEventScreenDrag and event.index == 0 and isZoom:
				newMousePosition = event.position
				allowRotation = false
		elif (event is InputEventMouseButton and (event.button_index == 4 or event.button_index == 5) and event.is_pressed() and !allowSelect and !isPressed and !isCameraRotating):
			# TODO: Continue here: Difference between (event.button_index == 4 or event.button_index == 5) to add or substract zoom and increase forced touchDistance.
			if event.button_index == 4:
				newMousePosition = Vector2.DOWN*30
				prevTouchDistance = 1.0
			else:	# event.button_index == 5
				newMousePosition = Vector2.UP
				prevTouchDistance = 30.0
			isZoom = true
			secondTouch = Vector2.ZERO
		elif !event.is_pressed():
			if ((event is InputEventScreenTouch or event is InputEventScreenDrag) and event.index == 0) or (event is InputEventMouseButton and event.button_index == 1):
				isPressed = false
				isCameraRotating = false
				isFirstFrameRotating = true
				allowRotation = false
				rotateDeadZone = Vector2.ZERO
				prevDragMotionEvent = null
				newMousePosition = Vector2.ZERO
				isZoom = false
				secondTouch = null
				prevTouchDistance = -1.0
			elif ((event is InputEventScreenTouch or event is InputEventScreenDrag) and event.index == 1) or (event is InputEventMouseButton and (event.button_index == 4 or event.button_index == 5)):
				if (event is InputEventMouseButton and (event.button_index == 4 or event.button_index == 5)): await get_tree().create_timer(0.1).timeout
				print("End Zoom")
				isZoom = false
				secondTouch = null
				prevTouchDistance = -1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# debugLabel.text = str(pivotRotation.rotation_degrees)
	if isMoving:
		var moveProgress = clampf(elapsedMovingTime / moveDuration, 0.0, 1.0)
		var currentPosition = moveInitialPosition.lerp(moveFinalPosition, moveProgress)
		pivotPosition.global_transform.origin = currentPosition
		elapsedMovingTime += delta
		if moveProgress >= 1.0:
			isMoving = false
			elapsedMovingTime = 0.0
	elif isCameraRotating:
		if !isFirstFrameRotating:
			var diffMousePosition = newMousePosition - prevMousePosition
			pivotRotation.rotation_degrees.x -= diffMousePosition.y/CAMERA_MOVE_SENSITIVITY
			pivotRotation.rotation_degrees.x = clampf(pivotRotation.rotation_degrees.x, 0.0, 85.0)
			pivotRotation.rotation_degrees.y -= diffMousePosition.x/CAMERA_MOVE_SENSITIVITY
			isCameraRotating = false
		else:
			isFirstFrameRotating = false
		prevMousePosition = newMousePosition
	elif isZoom and newMousePosition != Vector2.ZERO and secondTouch != null:
		print("ZOOOM PROCESS")
		if prevTouchDistance > 0.0:
			var currentDistance = newMousePosition.distance_to(secondTouch)
			var touchDistanceIncrement = currentDistance-prevTouchDistance
			#debugLabel.text = "newMousePosition:"+str(newMousePosition) + " | secondTouch: "+str(secondTouch) + " | currentDistance: "+str(currentDistance) + " | prevTouchDistance: "+str(prevTouchDistance) + " | touchDistanceIncrement" + str(touchDistanceIncrement) + "\n" + debugLabel.text
			self.position.y -= touchDistanceIncrement/100
			self.position.y = clampf(self.position.y, 1.0, 5.0)
			prevTouchDistance = currentDistance
		else:
			var currentDistance = newMousePosition.distance_to(secondTouch)
			prevTouchDistance = currentDistance
	elif secondTouch == null:
		prevTouchDistance = 0.0


func shootRay(eventPosition : Vector2) -> void:
	var ray_length = 1000
	var from = project_ray_origin(eventPosition)
	var to = from + project_ray_normal(eventPosition) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)
	if 'collider' in raycast_result:
		var colParent = raycast_result.collider.get_parent()
		if colParent is Tile3D:
			selectSquare(colParent)

func selectSquare(square: Tile3D) -> void:
	if squareSelected:
		squareSelected.deselect()
	squareSelected = square
	squareSelected.select()
	setupMoveToSquare(squareSelected)
	
func setupMoveToSquare(square: Tile3D) -> void:
	moveInitialPosition = pivotPosition.position
	moveFinalPosition = Vector3(square.position_in_board.x, pivotPosition.position.y, square.position_in_board.y)
	isMoving = true
