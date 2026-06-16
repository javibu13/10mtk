extends Control
class_name SettingsMenu

const SETTINGS_FILE_PATH := "user://settings.cfg"
var config := ConfigFile.new()

@onready var display_v_box_container: VBoxContainer = $Settings_VBoxContainer/Display_VBoxContainer
@onready var window_mode_option_button: OptionButton = $Settings_VBoxContainer/Display_VBoxContainer/WindowMode_HBoxContainer/WindowMode_OptionButton
@onready var master_audio_h_slider: HSlider = $Settings_VBoxContainer/Audio_VBoxContainer/Master_HBoxContainer/MasterAudio_HSlider
@onready var music_audio_h_slider: HSlider = $Settings_VBoxContainer/Audio_VBoxContainer/Music_HBoxContainer/MusicAudio_HSlider
@onready var sfx_audio_h_slider: HSlider = $Settings_VBoxContainer/Audio_VBoxContainer/SFX_HBoxContainer/SFXAudio_HSlider
@onready var return_button: Button = $Settings_VBoxContainer/Return_Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()
	load_settings()
	window_mode_option_button.item_selected.connect(change_window_mode_index_to_id)
	master_audio_h_slider.value_changed.connect(change_bus_volume.bind("Master"))
	music_audio_h_slider.value_changed.connect(change_bus_volume.bind("Music"))
	sfx_audio_h_slider.value_changed.connect(change_bus_volume.bind("SFX"))
	return_button.pressed.connect(exit_settings_menu)
	if not OS.has_feature("pc"):
		display_v_box_container.hide()

func exit_settings_menu() -> void:
	self.hide()


func change_window_mode_index_to_id(index: int) -> void:
	var item_id = window_mode_option_button.get_item_id(index)
	apply_window_mode_settings(item_id)


func change_window_mode_id_to_index(id: int) -> void:
	var item_index = window_mode_option_button.get_item_index(id)
	window_mode_option_button.select(item_index)
	apply_window_mode_settings(item_index)


func change_bus_volume(new_value: float, bus_name: String) -> void:
	apply_audio_bus_volume(bus_name, new_value)


func apply_default_settings() -> void:
	DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)


func load_settings() -> void:
	var config_load_result = config.load(SETTINGS_FILE_PATH)
	if config_load_result != OK:
		print("No settings file found. Default settings will be applied")
		apply_default_settings()
		return
	# Display
	var window_mode_int: int = config.get_value("display", "window_mode", 0)
	# Audio
	var master_vol = config.get_value("audio", "master_volume", 0.5)
	var music_vol = config.get_value("audio", "music_volume", 1.0)
	var sfx_vol = config.get_value("audio", "sfx_volume", 1.0)
	# Apply settings
	apply_window_mode_settings(window_mode_int)
	apply_audio_bus_volume("Master", master_vol)
	apply_audio_bus_volume("Music", music_vol)
	apply_audio_bus_volume("SFX", sfx_vol)
	# Load settings in UI
	change_window_mode_id_to_index(window_mode_int)
	master_audio_h_slider.value = master_vol
	music_audio_h_slider.value = music_vol
	sfx_audio_h_slider.value = sfx_vol


func apply_window_mode_settings(window_mode_int: int) -> void:
	match window_mode_int:
		0:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
		3:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
		4:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	config.set_value("display", "window_mode", window_mode_int)
	config.save(SETTINGS_FILE_PATH)


func apply_audio_bus_volume(bus_name: String, linear_value: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		# Convert linear value [0.0-1.0] to decibels
		var db_value = linear_to_db(linear_value)
		AudioServer.set_bus_volume_db(bus_index, db_value)
		# Audio bus could be muted to save CPU
		AudioServer.set_bus_mute(bus_index, linear_value <= 0.0)
		config.set_value("audio", bus_name.to_lower() + "_volume", linear_value)
		config.save(SETTINGS_FILE_PATH)
	else:
		Log.pr("No audio bus found under the name: ", bus_name)


func save_settings() -> void:
	# TODO: Allow user to store settings manually. Currently, settings are saved automatically after any change
	pass
