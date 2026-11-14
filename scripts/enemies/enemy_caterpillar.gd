extends CharacterBody2D

@export var speed: float = 50.0
@export var patrol_range: float = 120.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox

var start_x: float = 0.0
var direction: float = 1.0
var is_defeated: bool = false

func _ready() -> void:
	start_x = global_position.x
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)

func _physics_process(delta: float) -> void:
	if is_defeated:
		return

	if global_position.x > start_x + patrol_range:
		direction = -1.0
	elif global_position.x < start_x - patrol_range:
		direction = 1.0

	velocity.x = direction * speed
	velocity.y = 200.0
	if sprite:
		sprite.flip_h = (direction < 0)
		var t = Time.get_ticks_msec() / 150.0
		sprite.scale.x = 1.0 + sin(t) * 0.1

	move_and_slide()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if is_defeated:
		return
	if body.is_in_group("player") and body.velocity.y >= -50.0:
		is_defeated = true
		if body.has_method("bounce"):
			body.bounce(620.0, 0.0, false)

		_defeat_anim()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_defeated:
		return
	if body.is_in_group("player"):
		var knock_dir = Vector2(direction, -0.6).normalized()
		if has_node("/root/GameManager"):
			GameManager.take_damage(1)
		if body.has_method("apply_knockback"):
			body.apply_knockback(knock_dir, 380.0)

func _defeat_anim() -> void:
	var tw = create_tween()
	tw.tween_property(sprite, "scale", Vector2(1.5, 0.2), 0.15)
	tw.tween_property(sprite, "modulate:a", 0.0, 0.15)
	tw.tween_callback(queue_free)
