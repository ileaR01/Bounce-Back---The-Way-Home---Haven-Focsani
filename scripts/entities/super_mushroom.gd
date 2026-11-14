extends Area2D

@export var bounce_force: float = 920.0
@onready var sprite: Sprite2D = $Sprite2D
var can_bounce: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not can_bounce:
		return
	if body.is_in_group("player"):
		var vy = body.velocity.y if "velocity" in body else 0.0
		if vy >= -80.0:
			can_bounce = false
			if body.has_method("bounce"):
				body.bounce(bounce_force, 0.0, true)
			_animate_bounce()
			await get_tree().create_timer(0.3).timeout
			can_bounce = true

func _animate_bounce() -> void:
	if not sprite:
		return
	var t = create_tween()
	t.tween_property(sprite, "scale", Vector2(1.45, 0.5), 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(sprite, "scale", Vector2(0.75, 1.35), 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
