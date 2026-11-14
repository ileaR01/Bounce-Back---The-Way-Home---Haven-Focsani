extends Area2D
class_name RunePillar

signal pillar_activated(pillar_id: int)

@export var pillar_id: int = 1
@export var rune_label: String = ""
@export var glow_color: Color = Color(0.2, 0.75, 1.0)

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
var is_active: bool = false
var label_node: Label

const DEFAULT_RUNE_LABELS = {
	1: "1. LUNĂ 🌙",
	2: "2. SOARE ☀️",
	3: "3. FRUNZĂ 🍃",
	4: "4. STEA ★"
}

func _ready() -> void:
	if rune_label == "":
		rune_label = DEFAULT_RUNE_LABELS.get(pillar_id, "RUNĂ " + str(pillar_id))
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		sprite.position = Vector2(0, -46)
		add_child(sprite)
	if ResourceLoader.exists("res://assets/elements/rune_pillar.svg"):
		sprite.texture = load("res://assets/elements/rune_pillar.svg")

	label_node = Label.new()
	label_node.position = Vector2(-60, -82)
	label_node.size = Vector2(120, 22)
	label_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_node.add_theme_font_size_override("font_size", 13)
	label_node.add_theme_color_override("font_color", Color(0.95, 0.92, 0.85))
	label_node.text = rune_label
	add_child(label_node)

	body_entered.connect(_on_body_entered)
	_reset_visuals()

func _on_body_entered(body: Node2D) -> void:
	if is_active:
		return
	if body.is_in_group("player"):
		is_active = true
		_glow()
		pillar_activated.emit(pillar_id)

func _glow() -> void:
	if sprite:
		var tw = create_tween()
		tw.tween_property(sprite, "modulate", glow_color * 1.5, 0.15)
	if label_node:
		label_node.add_theme_color_override("font_color", glow_color.lightened(0.25))

func reset_pillar() -> void:
	is_active = false
	if sprite:
		var tw = create_tween()
		tw.tween_property(sprite, "modulate", Color(1.0, 0.3, 0.3), 0.2)
		tw.tween_property(sprite, "modulate", Color.WHITE, 0.3)
	if label_node:
		label_node.add_theme_color_override("font_color", Color(0.95, 0.92, 0.85))

func _reset_visuals() -> void:
	if sprite:
		sprite.modulate = Color.WHITE
