extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var speaker_label: Label = $Panel/SpeakerLabel
@onready var text_label: RichTextLabel = $Panel/TextLabel
@onready var avatar_rect: TextureRect = $Panel/AvatarRect
@onready var advance_button: Button = $Panel/AdvanceButton

var avatars: Dictionary = {}

var full_text: String = ""
var is_typing: bool = false
var type_tween: Tween
var last_sound_char: int = 0

func _ready() -> void:
	_init_avatars()
	panel.visible = false
	panel.pivot_offset = Vector2(500, 80)
	if advance_button:
		advance_button.focus_mode = Control.FOCUS_NONE
		advance_button.pressed.connect(_on_advance_pressed)

	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_line.connect(_on_dialogue_line)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _init_avatars() -> void:
	avatars["butterfly"] = preload("res://assets/exported/flutureNpc.svg")
	avatars["firefly"] = preload("res://assets/elements/npc_firefly.svg")
	avatars["flower"] = preload("res://assets/exported/npc_flower.svg")
	avatars["rabbit"] = preload("res://assets/exported/npc_rabbit.svg")
	avatars["turtle"] = preload("res://assets/exported/npc_turtle.svg")
	avatars["wind_bird"] = preload("res://assets/elements/npc_wind_bird.svg")
	avatars["guardian"] = preload("res://assets/elements/npc_guardian.svg")
	avatars["boy"] = preload("res://assets/player/boy/default.svg")
	avatars["girl"] = preload("res://assets/player/girl/default.svg")

func _process(_delta: float) -> void:
	if is_typing and text_label:
		var cur_c = text_label.visible_characters
		if cur_c > last_sound_char + 2:
			last_sound_char = cur_c

func _input(event: InputEvent) -> void:
	if not panel.visible or not DialogueManager.is_active:
		return

	var should_advance = false
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_ENTER or event.physical_keycode == KEY_ENTER or \
		   event.keycode == KEY_KP_ENTER or event.physical_keycode == KEY_KP_ENTER or \
		   event.keycode == KEY_SPACE or event.physical_keycode == KEY_SPACE or \
		   event.keycode == KEY_E or event.physical_keycode == KEY_E:
			should_advance = true
	elif event.is_action_pressed("interact") or event.is_action_pressed("jump"):
		should_advance = true

	if should_advance:
		get_viewport().set_input_as_handled()
		_on_advance_pressed()

func _on_dialogue_started() -> void:
	panel.visible = true
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.92, 0.92)
	var tw = create_tween()
	tw.tween_property(panel, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(panel, "scale", Vector2(1.0, 1.0), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_dialogue_line(speaker: String, text: String, avatar: String) -> void:
	speaker_label.text = speaker
	full_text = text
	text_label.text = ""
	last_sound_char = 0

	var resolved_avatar = avatar
	if resolved_avatar == "player":
		resolved_avatar = GameManager.current_character if has_node("/root/GameManager") else "boy"

	if avatars.has(resolved_avatar):
		avatar_rect.texture = avatars[resolved_avatar]
		avatar_rect.visible = true
	else:
		avatar_rect.visible = false

	_start_typewriter(text)

func _start_typewriter(text: String) -> void:
	if type_tween and type_tween.is_valid():
		type_tween.kill()

	is_typing = true
	text_label.text = text
	text_label.visible_characters = 0
	last_sound_char = 0

	var dur = max(0.28, text.length() * 0.018)
	type_tween = create_tween()
	type_tween.tween_property(text_label, "visible_characters", text.length(), dur)
	type_tween.finished.connect(func(): is_typing = false)

func _on_advance_pressed() -> void:
	if is_typing:
		if type_tween and type_tween.is_valid():
			type_tween.kill()
		text_label.visible_characters = full_text.length()
		is_typing = false
	else:
		DialogueManager.advance_dialogue()

func _on_dialogue_ended() -> void:
	is_typing = false
	if type_tween and type_tween.is_valid():
		type_tween.kill()
	var tw = create_tween()
	tw.tween_property(panel, "modulate:a", 0.0, 0.14)
	tw.tween_callback(func(): panel.visible = false)
