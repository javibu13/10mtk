extends Control
class_name InvestigateScene

const AFFIRMATIVE_ANSWERS := ["Yes...", "Y-yes...", "I... I suppose so", "I'm affraid so", "Yes, officer...", "I won't deny it"]
const NEGATIVE_ANSWERS := ["No!", "Nah", "No way!", "Not at all", "Nope", "Hell no!"]

@onready var action_executor: ActionExecutor = $"../../ActionExecutor"
@onready var police_character_texture_rect: TextureRect = $HBoxContainer/LeftCharacter_Control/Character_TextureRect
@onready var character_texture_rect: TextureRect = $HBoxContainer/RightCharacter_Control/Character_TextureRect
@onready var police_ask_rich_text_label: RichTextLabel = $HBoxContainer/LeftCharacter_Control/BubbleText_CenterContainer/Ask_RichTextLabel
@onready var character_answer_rich_text_label: RichTextLabel = $HBoxContainer/RightCharacter_Control/BubbleText_CenterContainer/Answer_RichTextLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()


func play_movement_sound() -> void:
	SoundManager.instance_and_play_sound(null, SoundManager.character_move_sfx)


func play_jail_door_sound() -> void:
	SoundManager.instance_and_play_sound(null, SoundManager.jail_door_sfx)


func investigate_anim_ended() -> void:
	action_executor.continue_investigate_action.emit()


func start_anim(police_character: Enums.Character, character_asked: Enums.Character, player_user_name: String, is_correct_assassin: bool) -> void:
	police_character_texture_rect.texture = load(Enums.CHARACTER_INFO[police_character].image_path)
	police_ask_rich_text_label.text = str(player_user_name, "?")
	character_texture_rect.texture = load(Enums.CHARACTER_INFO[character_asked].image_path)
	character_texture_rect.flip_h = Enums.CHARACTER_INFO[character_asked].facing_direction == "right"
	character_answer_rich_text_label.text = AFFIRMATIVE_ANSWERS.pick_random() if is_correct_assassin else NEGATIVE_ANSWERS.pick_random()
	animation_player.play("investigate")
	self.show()


func jail_door_anim() -> void:
	animation_player.play("jail_door_close")


func hide_anim() -> void:
	animation_player.play("hide")


func hide_self_and_continue() -> void:
	action_executor.continue_investigate_action.emit()
	self.hide()
