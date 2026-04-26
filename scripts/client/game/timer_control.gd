@tool
extends Control
class_name TimerControl

enum Position {
	BOTTOM,
	LEFT,
	TOP,
	RIGHT,
}

## Time remaining in turn in seconds
var left_time: int

@onready var h_box_container: HBoxContainer = $Position_Control/HBoxContainer
@onready var animation_player: AnimationPlayer = $Position_Control/AnimationPlayer
@onready var timer: Timer = $Timer
@onready var action_rich_text_label: RichTextLabel = $Position_Control/HBoxContainer/Action_RichTextLabel
@onready var timer_rich_text_label: RichTextLabel = $Position_Control/HBoxContainer/CenterContainer/PanelContainer/Timer_RichTextLabel

@export var game_root: GameRootNode
@export var screen_location: Position
@export var trigger_position_update_in_editor: bool:
	set(value):
		trigger_position_update_in_editor = value
		h_box_container.position.x = -70.0 + x_position_increment
		h_box_container.position.y = y_position_increment
@export var enable_position_change_in_editor: bool = false
@export var x_position_increment: float:
	set(x):
		x_position_increment = x
		if enable_position_change_in_editor and Engine.is_editor_hint():
			h_box_container.position.x = -70.0 + x
@export var y_position_increment: float:
	set(y):
		y_position_increment = y
		if enable_position_change_in_editor and Engine.is_editor_hint():
			h_box_container.position.y = y


func _ready() -> void:
	match screen_location:
		Position.BOTTOM:
			x_position_increment = 0
			y_position_increment = -20
		Position.LEFT:
			x_position_increment = 128
			y_position_increment = 0
		Position.TOP:
			x_position_increment = 0
			y_position_increment = 60
		Position.RIGHT:
			x_position_increment = -85
			y_position_increment = 0
	h_box_container.position.x = -70.0 + x_position_increment
	h_box_container.position.y = y_position_increment
	timer.timeout.connect(_timer_timeout)


func set_hidden() -> void:
	match screen_location:
		Position.BOTTOM:
			animation_player.play("hidden_bottom")
		Position.LEFT:
			animation_player.play("hidden_left")
		Position.TOP:
			animation_player.play("hidden_top")
		Position.RIGHT:
			animation_player.play("hidden_right")


func show_anim():
	match screen_location:
		Position.BOTTOM:
			animation_player.play("show_bottom_to_top")
		Position.LEFT:
			animation_player.play("show_left_to_right")
		Position.TOP:
			animation_player.play("show_top_to_bottom")
		Position.RIGHT:
			animation_player.play("show_right_to_left")


func hide_anim():
	timer.stop()
	match screen_location:
		Position.BOTTOM:
			animation_player.play("hide_top_to_bottom")
		Position.LEFT:
			animation_player.play("hide_right_to_left")
		Position.TOP:
			animation_player.play("hide_bottom_to_top")
		Position.RIGHT:
			animation_player.play("hide_left_to_right")


func set_and_start_timer(new_time: int) -> void:
	left_time = new_time
	_update_visual_timer(left_time)
	timer.start()


func set_action_number(new_action_number: int) -> void:
	action_rich_text_label.text = str(new_action_number, "/2")


func _timer_timeout() -> void:
	left_time -= 1
	# Check if new time is lower than 0 to allow player to play his turn in the very last second
	if left_time < 0:
		game_root.turn_timeout.emit()
	else:
		# Update visual timer
		_update_visual_timer(left_time)


# Set in the timer_rich_text_label the turn time (in seconds) remaining in the format: MM:SS
func _update_visual_timer(time: int) -> void:
	@warning_ignore("integer_division")
	var minutes: int = time/60
	var seconds: int = time%60
	timer_rich_text_label.text = str(minutes).lpad(2, "0") + ":" + str(seconds).lpad(2, "0")
