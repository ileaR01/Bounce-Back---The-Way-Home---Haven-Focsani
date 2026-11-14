extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
var is_triggered: bool = false
const VORTEX_CENTER = Vector2(0, -68)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	var t = Time.get_ticks_msec() / 1000.0
	if sprite and not is_triggered:
		sprite.scale = Vector2(1.0 + sin(t * 2.8) * 0.03, 1.0 + cos(t * 2.8) * 0.03)

func _on_body_entered(body: Node2D) -> void:
	if is_triggered:
		return
	if body.is_in_group("player"):
		is_triggered = true
		_trigger_portal_transition(body)

func _trigger_portal_transition(player: Node2D) -> void:
	if has_node("/root/GameManager"):
		GameManager.complete_level()

	if "velocity" in player:
		player.velocity = Vector2.ZERO
	if player.has_method("trigger_camera_shake"):
		player.trigger_camera_shake(9.0, 0.45)

	var p_tw = create_tween()
	var target_pos = global_position + VORTEX_CENTER
	p_tw.tween_property(player, "global_position", target_pos, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	p_tw.parallel().tween_property(player, "scale", Vector2.ZERO, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	p_tw.parallel().tween_property(player, "rotation", 2.0, 0.55)

	if sprite:
		var s_tw = create_tween()
		s_tw.tween_property(sprite, "scale", Vector2(1.4, 1.4), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		s_tw.parallel().tween_property(sprite, "modulate", Color(2.0, 2.0, 2.5), 0.25)
		s_tw.tween_property(sprite, "scale", Vector2(0.9, 0.9), 0.3)

	await get_tree().create_timer(0.9).timeout
	if has_node("/root/LevelManager"):
		LevelManager.next_level()
