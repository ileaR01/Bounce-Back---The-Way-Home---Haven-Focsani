extends CharacterBody2D

@export var speed: float = 35.0
@export var patrol_range: float = 100.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox

var start_x: float = 0.0
var direction: float = 1.0
var is_shell_mode: bool = false

func _ready() -> void:
	start_x = global_position.x
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)

func _physics_process(delta: float) -> void:
	if not is_shell_mode:
		if global_position.x > start_x + patrol_range:
			direction = -1.0
		elif global_position.x < start_x - patrol_range:
			direction = 1.0

		velocity.x = direction * speed
		velocity.y = 200.0
		if sprite:
			sprite.flip_h = (direction < 0)
	else:
		velocity.x = 0
		velocity.y = 200.0

	move_and_slide()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.velocity.y >= -50.0:
		if body.has_method("bounce"):
			body.bounce(740.0, 0.0, true)

		if not is_shell_mode:
			is_shell_mode = true
			var tw = create_tween()
			tw.tween_property(sprite, "scale", Vector2(1.2, 0.7), 0.1)
			tw.tween_property(sprite, "scale", Vector2(0.9, 0.9), 0.1)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_shell_mode:
		if body.is_in_group("player") and body.has_method("bounce"):
			body.bounce(650.0, 0.0, false)
		return

	if body.is_in_group("player"):
		var knock_dir = Vector2(direction, -0.6).normalized()
		if has_node("/root/GameManager"):
			GameManager.take_damage(1)
		if body.has_method("apply_knockback"):
			body.apply_knockback(knock_dir, 380.0)
