extends Area2D
class_name MovingBlade

@export var move_offset: Vector2 = Vector2(140, 0)
@export var move_duration: float = 2.2
@export var blade_radius: float = 22.0

var start_pos: Vector2
var sprite: Sprite2D

func _ready() -> void:
	start_pos = position
	collision_layer = 0
	collision_mask = 2

	sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		add_child(sprite)
	if ResourceLoader.exists("res://assets/elements/moving_blade.svg"):
		sprite.texture = load("res://assets/elements/moving_blade.svg")

	if not has_node("CollisionShape2D"):
		var col := CollisionShape2D.new()
		col.name = "CollisionShape2D"
		var cir := CircleShape2D.new()
		cir.radius = blade_radius * 0.85
		col.shape = cir
		add_child(col)
	body_entered.connect(_on_body_entered)
	var tw = create_tween().set_loops().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tw.tween_property(self, "position", start_pos + move_offset, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(self, "position", start_pos, move_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _process(delta: float) -> void:
	if sprite:
		sprite.rotation += delta * 10.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var dir = (body.global_position - global_position).normalized()
		if dir.y > -0.3:
			dir.y = -0.7
		if has_node("/root/GameManager"):
			GameManager.take_damage(1)
		if body.has_method("apply_knockback"):
			body.apply_knockback(dir, 390.0)
