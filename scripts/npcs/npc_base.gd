extends Area2D
class_name NPCBase

@export var npc_name: String = "Licuriciul Magic"
@export var avatar_key: String = "firefly"
@export var npc_visual_type: String = "firefly"
@export var auto_trigger: bool = false
@export var vanish_after_dialogue: bool = false
@export var grant_special_item_on_finish: String = ""
@export var dialogue_lines: Array[String] = []
@export var repeat_dialogue_lines: Array[String] = []

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var prompt: Sprite2D = get_node_or_null("PromptSprite")

var player_in_range: bool = false
var has_auto_triggered: bool = false
var conversation_count: int = 0
var can_trigger: bool = true
var is_vanished: bool = false
var waiting_for_this_dialogue: bool = false
var prompt_label: Label

const NPC_SVGS := {
	"firefly": "res://assets/elements/npc_firefly.svg",
	"wind_bird": "res://assets/elements/npc_wind_bird.svg",
	"guardian": "res://assets/elements/npc_guardian.svg",
	"rabbit": "res://assets/exported/npc_rabbit.svg",
	"turtle": "res://assets/exported/npc_turtle.svg",
	"butterfly": "res://assets/exported/flutureNpc.svg",
	"flower": "res://assets/exported/npc_flower.svg"
}

func _ready() -> void:
	if prompt:
		prompt.visible = false
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		sprite.position = Vector2(0, -24)
		add_child(sprite)
	sprite.visible = true
	if NPC_SVGS.has(npc_visual_type):
		var svg_path: String = NPC_SVGS[npc_visual_type]
		if ResourceLoader.exists(svg_path):
			sprite.texture = load(svg_path)

	prompt_label = Label.new()
	prompt_label.name = "PromptLabel"
	prompt_label.position = Vector2(-90, -68)
	prompt_label.size = Vector2(180, 24)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 13)
	prompt_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.65, 0.95))
	prompt_label.text = "[E] Vorbește cu " + npc_name
	prompt_label.visible = false
	add_child(prompt_label)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if has_node("/root/DialogueManager"):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_ended() -> void:
	if waiting_for_this_dialogue:
		waiting_for_this_dialogue = false
		if grant_special_item_on_finish != "" and has_node("/root/GameManager"):
			GameManager.unlock_special_item(grant_special_item_on_finish)
			grant_special_item_on_finish = ""
		if vanish_after_dialogue and not is_vanished:
			_vanish()
	can_trigger = false
	var tree = get_tree()
	if tree:
		await tree.create_timer(0.4).timeout
	can_trigger = true

func _vanish() -> void:
	is_vanished = true
	if prompt:
		prompt.visible = false
	if prompt_label:
		prompt_label.visible = false
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "position:y", position.y - 36.0, 0.55)
	tw.tween_callback(func(): visible = false)

func _process(_delta: float) -> void:
	if is_vanished:
		return
	if sprite:
		var t = Time.get_ticks_msec() / 1000.0
		sprite.position.y = -24.0 + sin(t * 3.0) * 4.5
	if prompt_label:
		prompt_label.visible = (player_in_range and can_trigger and not DialogueManager.is_active)

func _unhandled_input(event: InputEvent) -> void:
	if is_vanished or not player_in_range or not can_trigger:
		return
	if has_node("/root/DialogueManager") and DialogueManager.is_active:
		return

	var wants_talk = false
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_E or event.physical_keycode == KEY_E or \
		   event.keycode == KEY_ENTER or event.physical_keycode == KEY_ENTER or \
		   event.keycode == KEY_KP_ENTER or event.physical_keycode == KEY_KP_ENTER:
			wants_talk = true
	elif event.is_action_pressed("interact"):
		wants_talk = true

	if wants_talk:
		get_viewport().set_input_as_handled()
		trigger_dialogue()

func _on_body_entered(body: Node2D) -> void:
	if is_vanished:
		return
	if body.is_in_group("player"):
		player_in_range = true
		if prompt:
			prompt.visible = true
		if auto_trigger and not has_auto_triggered:
			has_auto_triggered = true
			trigger_dialogue()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if prompt:
			prompt.visible = false

func trigger_dialogue() -> void:
	if is_vanished:
		return
	var active_lines: Array[String] = dialogue_lines
	if conversation_count > 0 and not repeat_dialogue_lines.is_empty():
		active_lines = repeat_dialogue_lines
	if active_lines.is_empty():
		return

	conversation_count += 1
	waiting_for_this_dialogue = true
	var queue: Array = []

	for raw_line in active_lines:
		var speaker = npc_name
		var avatar = avatar_key
		var text = raw_line
		if raw_line.begins_with("JUCĂTORUL:"):
			speaker = "EU"
			avatar = "player"
			text = raw_line.trim_prefix("JUCĂTORUL:").strip_edges()
		elif raw_line.begins_with("LICURICIUL:"):
			speaker = "Licuriciul Magic"
			avatar = "firefly"
			text = raw_line.trim_prefix("LICURICIUL:").strip_edges()
		elif raw_line.begins_with("IEPURAȘUL:"):
			speaker = "Iepurașul Prietenos"
			avatar = "rabbit"
			text = raw_line.trim_prefix("IEPURAȘUL:").strip_edges()
		elif raw_line.begins_with("ȚESTOASA:"):
			speaker = "Țestoasa Înțeleaptă"
			avatar = "turtle"
			text = raw_line.trim_prefix("ȚESTOASA:").strip_edges()
		elif raw_line.begins_with("PASĂREA:"):
			speaker = "Pasărea Vântului"
			avatar = "wind_bird"
			text = raw_line.trim_prefix("PASĂREA:").strip_edges()
		elif raw_line.begins_with("GUARDIANUL:"):
			speaker = "Guardianul Sanctuarului"
			avatar = "guardian"
			text = raw_line.trim_prefix("GUARDIANUL:").strip_edges()
		queue.append({
			"speaker": speaker,
			"avatar": avatar,
			"text": text
		})
	if has_node("/root/DialogueManager"):
		DialogueManager.start_dialogue(queue)
