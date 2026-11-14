extends StaticBody2D
class_name RuneGate

@export var is_locked: bool = true
@onready var sprite: Sprite2D = $Sprite2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	if not is_locked:
		unlock(false)

func _process(delta: float) -> void:
	if is_locked and sprite:
		var t = Time.get_ticks_msec() / 1000.0
		sprite.modulate.a = 0.88 + sin(t * 3.5) * 0.12

func unlock(animate: bool = true) -> void:
	is_locked = false
	if animate:
		var tw = create_tween()
		tw.tween_property(sprite, "modulate:a", 0.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(sprite, "scale:y", 0.1, 0.45)
		tw.tween_callback(func():
			if col_shape:
				col_shape.set_deferred("disabled", true)
			visible = false
		)
	else:
		if col_shape:
			col_shape.set_deferred("disabled", true)
		visible = false
