extends StaticBody2D
class_name CrumblingPlatform

@export var crumble_delay: float = 0.38
@export var respawn_time: float = 3.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D
@onready var trigger_area: Area2D = $TriggerArea

var is_crumbling: bool = false
var original_pos: Vector2

func _ready() -> void:
	original_pos = sprite.position
	trigger_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if is_crumbling:
		return
	if body.is_in_group("player"):
		_start_crumble()

func _start_crumble() -> void:
	is_crumbling = true

	var tw = create_tween().set_loops(6)
	tw.tween_property(sprite, "position:x", original_pos.x + 3.0, 0.03)
	tw.tween_property(sprite, "position:x", original_pos.x - 3.0, 0.03)

	var timer = get_tree().create_timer(crumble_delay)
	await timer.timeout

	col_shape.set_deferred("disabled", true)
	var fade_tw = create_tween()
	fade_tw.tween_property(sprite, "modulate:a", 0.0, 0.25)
	fade_tw.parallel().tween_property(sprite, "position:y", original_pos.y + 20.0, 0.25)

	await get_tree().create_timer(respawn_time).timeout
	_respawn()

func _respawn() -> void:
	sprite.position = original_pos
	var respawn_tw = create_tween()
	respawn_tw.tween_property(sprite, "modulate:a", 1.0, 0.4)
	await respawn_tw.finished
	col_shape.set_deferred("disabled", false)
	is_crumbling = false
