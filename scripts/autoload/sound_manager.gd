extends Node

var main_menu_music_resource: Resource = preload("res://sounds/music/main_menu_trouble_makers_loop.wav")
var in_game_music_resource: Resource = preload("res://sounds/music/in_game_midnight_on_miller_street_loopable.mp3")
var button_mouse_entered_sfx_resource: Resource = preload("res://sounds/sfx/buttons/bong_001.ogg")
var button_mouse_pressed_sfx_resource: Resource = preload("res://sounds/sfx/buttons/click_001.ogg")
var button_select_sfx_resource: Resource = preload("res://sounds/sfx/buttons/switch_005.ogg")
var background_music_audio_stream_player: AudioStreamPlayer


func _ready() -> void:
	background_music_audio_stream_player = AudioStreamPlayer.new()
	background_music_audio_stream_player.bus = "Music"
	background_music_audio_stream_player.stream = main_menu_music_resource
	background_music_audio_stream_player.volume_db = 0
	background_music_audio_stream_player.autoplay = false
	add_child(background_music_audio_stream_player)


func play_main_menu_music() -> void:
	if not background_music_audio_stream_player.stream == main_menu_music_resource or not background_music_audio_stream_player.playing:
		background_music_audio_stream_player.stop()
		background_music_audio_stream_player.stream = main_menu_music_resource
		background_music_audio_stream_player.play()


func play_in_game_music() -> void:
	if not background_music_audio_stream_player.stream == in_game_music_resource or not background_music_audio_stream_player.playing:
		background_music_audio_stream_player.stop()
		background_music_audio_stream_player.stream = in_game_music_resource
		background_music_audio_stream_player.play()


func stop_background_music() -> void:
	background_music_audio_stream_player.stop()


func resync_control_sounds() -> void:
	var buttons = get_tree().get_nodes_in_group("buttons")
	for button in buttons:
		if button is BaseButton:
			var button_base_button := button as BaseButton
			button_base_button.mouse_entered.connect(_instance_and_play_sound.bind(button_base_button, button_mouse_entered_sfx_resource, 0.0, 1))
			button_base_button.mouse_exited.connect(_instance_and_play_sound.bind(button_base_button, button_mouse_entered_sfx_resource, -10.0, 0.5))
			button_base_button.pressed.connect(_instance_and_play_sound.bind(button_base_button, button_mouse_pressed_sfx_resource, 0.0, 1))
		elif button is RichTextLabel:
			var button_rich_text_label := button as RichTextLabel
			button_rich_text_label.meta_hover_started.connect(_meta_instance_and_play_sound.bind(button_rich_text_label, button_mouse_entered_sfx_resource, 0.0, 1.2))
			button_rich_text_label.meta_hover_ended.connect(_meta_instance_and_play_sound.bind(button_rich_text_label, button_mouse_entered_sfx_resource, -10.0, 0.7))
			button_rich_text_label.meta_clicked.connect(_meta_instance_and_play_sound.bind(button_rich_text_label, button_mouse_pressed_sfx_resource, 0.0, 1))
	var line_edits = get_tree().get_nodes_in_group("lineEdits")
	for line_edit: LineEdit in line_edits:
		line_edit.mouse_entered.connect(_instance_and_play_sound.bind(line_edit, button_mouse_entered_sfx_resource, -8.0, 1.2))
		line_edit.mouse_exited.connect(_instance_and_play_sound.bind(line_edit, button_mouse_entered_sfx_resource, -16.0, 0.7))
		line_edit.editing_toggled.connect(_meta_instance_and_play_sound.bind(line_edit, button_select_sfx_resource, -5.0, 0.65))


func _instance_and_play_sound(button: Variant, sound_resource: Resource, volume_db: float = 0.0, pitch_scale: float = 1) -> void:
	if button is BaseButton and button.disabled:
		return
	#Log.pr(button.name)
	var tmp_audio_stream_player = AudioStreamPlayer.new()
	tmp_audio_stream_player.bus = "SFX"
	tmp_audio_stream_player.stream = sound_resource
	tmp_audio_stream_player.volume_db = volume_db
	tmp_audio_stream_player.pitch_scale = pitch_scale
	tmp_audio_stream_player.autoplay = true
	tmp_audio_stream_player.finished.connect(_queue_free_audio_stream_player.bind(tmp_audio_stream_player))
	add_child.call_deferred(tmp_audio_stream_player)


func _meta_instance_and_play_sound(meta, button: Variant, sound_resource: Resource, volume_db: float = 0.0, pitch_scale: float = 1) -> void:
	if meta is bool and meta == false:
		return
	_instance_and_play_sound(button, sound_resource, volume_db, pitch_scale)


func _queue_free_audio_stream_player(audio_stream_player: AudioStreamPlayer) -> void:
	audio_stream_player.queue_free.call_deferred()


func add_sound_signals_to_button(button: BaseButton) -> void:
	button.mouse_entered.connect(_instance_and_play_sound.bind(button, button_mouse_entered_sfx_resource, 0.0, 1))
	button.mouse_exited.connect(_instance_and_play_sound.bind(button, button_mouse_entered_sfx_resource, -10.0, 0.5))
	button.pressed.connect(_instance_and_play_sound.bind(button, button_mouse_pressed_sfx_resource, 0.0, 1))
