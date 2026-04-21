extends Control


var load_signals: Array[Signal] = []

@onready var game_root: Node3D = $"../.."
@onready var progress_bar: ProgressBar = $Default_VBoxContainer/LoadingInfo_VBoxContainer/ProgressBar


func _ready() -> void:
	load_signals.assign([game_root.token_character_resource_loaded,
				   game_root.board_built,
				   game_root.public_data_received,
				   game_root.tile_resource_loaded])
	for load_signal in load_signals:
		load_signal.connect(_update_progress_bar)


func _update_progress_bar() -> void:
	progress_bar.value += 100.0 / load_signals.size()
