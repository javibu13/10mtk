extends MarginContainer
class_name PointsItem

var points: int = 0
var description: String = ""
@onready var points_label: RichTextLabel = $HSplitContainer/Points_RichTextLabel
@onready var description_label: RichTextLabel = $HSplitContainer/Description_RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func set_up(new_points: int, new_description: String):
	points = new_points
	points_label.text = str("+", points) if points > 0 else str("-", points)
	description = new_description
	description_label.text = description
