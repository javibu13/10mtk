extends Control

@onready var return_button: Button = $CreditsScene_VBoxContainer/Return_Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	return_button.pressed.connect(func(): self.hide())
