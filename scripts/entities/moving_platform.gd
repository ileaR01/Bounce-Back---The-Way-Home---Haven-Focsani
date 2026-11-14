extends AnimatableBody2D

@export var move_offset: Vector2 = Vector2(160, 0)
@export var move_duration: float = 3.0

var start_pos: Vector2

func _ready() -> void:
	start_pos = position
	_start_tween()

func _start_tween() -> void:
	var tw = create_tween().set_loops().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tw.tween_property(self, "position", start_pos + move_offset, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "position", start_pos, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
