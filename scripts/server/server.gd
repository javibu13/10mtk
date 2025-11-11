extends Node

@export var vbox_container_print: VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NetworkManager.server_print_msg.connect(_on_server_print)
	print("Server working ⚙️...")
	_on_server_print("Server working ⚙️...")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_server_print(msg: String):
	var new_label := Label.new()
	new_label.text = msg
	vbox_container_print.add_child(new_label)
