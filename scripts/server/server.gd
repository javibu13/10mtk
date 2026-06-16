extends Node

@export var vbox_container_print: VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NetworkManager.server_print_msg.connect(_on_server_print)
	#Log.pr("Server working ⚙️...")
	NetworkManager.server_print_msg.emit("Server working ⚙️...")
	add_child(ServerGlobalData.http_request)
	SoundManager.stop_background_music()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_server_print(msg: String):
	var new_label := Label.new()
	new_label.text = msg
	vbox_container_print.add_child(new_label)
	Log.pr(msg)


func _is_valid_email(email: String) -> bool:
	# Basic email validation
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
	return regex.search(email) != null
