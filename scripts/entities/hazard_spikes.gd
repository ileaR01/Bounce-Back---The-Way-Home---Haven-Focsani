extends Area2D

@export var damage_amount: int = 1
@export var knockback_force: float = 380.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var dir = (body.global_position - global_position).normalized()
		if dir.y > -0.3:
			dir.y = -0.7
		var x_dir = sign(dir.x) if abs(dir.x) > 0.1 else 1.0
		dir.x = x_dir
		GameManager.take_damage(damage_amount)
		if body.has_method("apply_knockback"):
			body.apply_knockback(dir, knockback_force)
