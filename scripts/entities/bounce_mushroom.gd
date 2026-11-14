extends Area2D
class_name BounceMushroom

@export_enum("small", "medium", "large", "disappearing", "moving", "popup", "fake", "giant") var mushroom_type: String = "medium"
@export var bounce_force: float = 820.0
@export var horizontal_boost: float = 0.0
@export var move_offset: Vector2 = Vector2(120, 0)
@export var move_duration: float = 2.4

var start_pos: Vector2
var can_bounce: bool = true
var is_vanished: bool = false
var sprite: Sprite2D

const MUSHROOM_SVGS := {
	"small": "res://assets/elements/mushroom_small.svg",
	"medium": "res://assets/elements/mushroom_medium.svg",
	"large": "res://assets/elements/mushroom_large.svg",
	"disappearing": "res://assets/elements/mushroom_disappearing.svg",
	"moving": "res://assets/elements/mushroom_moving.svg",
	"popup": "res://assets/elements/mushroom_popup.svg",
	"fake": "res://assets/elements/mushroom_fake.svg",
	"giant": "res://assets/elements/mushroom_giant.svg"
}

const MUSHROOM_OFFSETS := {
	"small": Vector2(0, -23),
	"medium": Vector2(0, -27),
	"large": Vector2(0, -33),
	"disappearing": Vector2(0, -27),
	"moving": Vector2(0, -27),
	"popup": Vector2(0, -27),
	"fake": Vector2(0, -27),
	"giant": Vector2(0, -47)
}

func _ready() -> void:
	start_pos = position
	collision_layer = 0
	collision_mask = 2

	match mushroom_type:
		"small": bounce_force = 630.0
		"medium": bounce_force = 820.0
		"large": bounce_force = 1040.0
		"disappearing": bounce_force = 860.0
		"moving": bounce_force = 880.0
		"popup": bounce_force = 960.0
		"fake": bounce_force = 0.0
		"giant":
			if bounce_force < 1200.0:
				bounce_force = 1380.0
			if abs(horizontal_boost) < 10.0:
				horizontal_boost = 440.0

	sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		add_child(sprite)
	var svg_path: String = MUSHROOM_SVGS.get(mushroom_type, "res://assets/elements/mushroom_medium.svg")
	if ResourceLoader.exists(svg_path):
		sprite.texture = load(svg_path)
	sprite.position = MUSHROOM_OFFSETS.get(mushroom_type, Vector2(0, -27))

	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	var w: float = 110.0 if mushroom_type == "giant" else (68.0 if mushroom_type == "large" else (42.0 if mushroom_type == "small" else 54.0))
	var h: float = 54.0 if mushroom_type == "giant" else 34.0
	rect.size = Vector2(w, h)
	col.shape = rect
	col.position = Vector2(0, -h * 0.5)
	add_child(col)

	body_entered.connect(_on_body_entered)

	if mushroom_type == "moving":
		var tw = create_tween().set_loops().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tw.tween_property(self, "position", start_pos + move_offset, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(self, "position", start_pos, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_body_entered(body: Node2D) -> void:
	if not can_bounce or is_vanished:
		return
	if body.is_in_group("player"):
		var vy: float = body.velocity.y if "velocity" in body else 0.0
		if vy >= -80.0:
			_trigger_mushroom(body)

func _trigger_mushroom(player: Node2D) -> void:
	can_bounce = false
	if mushroom_type == "fake":
		if sprite:
			var ftw = create_tween()
			ftw.tween_property(sprite, "scale", Vector2(1.3, 0.45), 0.12)
			ftw.tween_property(sprite, "scale", Vector2.ONE, 0.35)
		await get_tree().create_timer(0.4).timeout
		can_bounce = true
		return

	var is_super = mushroom_type in ["large", "popup", "giant"]
	if mushroom_type == "popup":
		var ptw = create_tween()
		ptw.tween_property(self, "position:y", start_pos.y - 36.0, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		ptw.tween_property(self, "position:y", start_pos.y, 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	if player.has_method("bounce"):
		player.bounce(bounce_force, horizontal_boost, is_super)

	if sprite:
		var tw = create_tween()
		tw.tween_property(sprite, "scale", Vector2(1.32, 0.62), 0.08)
		tw.tween_property(sprite, "scale", Vector2(0.88, 1.18), 0.14)
		tw.tween_property(sprite, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	if mushroom_type == "disappearing":
		await get_tree().create_timer(0.18).timeout
		is_vanished = true
		var vtw = create_tween()
		vtw.tween_property(self, "modulate:a", 0.15, 0.2)
		await get_tree().create_timer(2.2).timeout
		var rtw = create_tween()
		rtw.tween_property(self, "modulate:a", 1.0, 0.25)
		is_vanished = false
		can_bounce = true
	else:
		await get_tree().create_timer(0.22).timeout
		can_bounce = true
