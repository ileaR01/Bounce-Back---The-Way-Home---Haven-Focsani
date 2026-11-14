extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
var tex_inactive = preload("res://assets/exported/checkpoint_inactive.svg")
var tex_active = preload("res://assets/exported/checkpoint_active.svg")
var is_activated: bool = false

func _ready() -> void:
	if sprite:
		sprite.texture = tex_inactive
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if is_activated:
		return
	if body.is_in_group("player"):
		activate()

func activate() -> void:
	is_activated = true
	if sprite:
		sprite.texture = tex_active
	if has_node("/root/GameManager"):
		GameManager.set_checkpoint(global_position + Vector2(0, -10))

	if sprite:
		var tw = create_tween()
		tw.tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
