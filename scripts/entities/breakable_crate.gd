extends StaticBody2D
class_name BreakableCrate

@export var coins_inside: int = 2
var is_broken: bool = false
var col_shape: CollisionShape2D
var hit_area: Area2D
var sprite: Sprite2D

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2

	sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		add_child(sprite)
	if ResourceLoader.exists("res://assets/elements/breakable_crate.svg"):
		sprite.texture = load("res://assets/elements/breakable_crate.svg")
	sprite.position = Vector2(0, -22)

	col_shape = CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(44, 44)
	col_shape.shape = box
	col_shape.position = Vector2(0, -22)
	add_child(col_shape)

	hit_area = Area2D.new()
	hit_area.collision_layer = 0
	hit_area.collision_mask = 2
	var hcol := CollisionShape2D.new()
	var hbox := RectangleShape2D.new()
	hbox.size = Vector2(48, 52)
	hcol.shape = hbox
	hcol.position = Vector2(0, -24)
	hit_area.add_child(hcol)
	add_child(hit_area)
	hit_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if is_broken:
		return
	if body.is_in_group("player"):
		var vy: float = body.velocity.y if "velocity" in body else 0.0
		if vy >= -40.0 or body.global_position.y < global_position.y - 16.0:
			_smash(body)

func _smash(player: Node2D) -> void:
	is_broken = true
	if col_shape:
		col_shape.set_deferred("disabled", true)

	if player.has_method("bounce"):
		player.bounce(540.0, 0.0, false)

	if has_node("/root/GameManager"):
		GameManager.collect_coin(coins_inside)

	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(1.35, 0.3), 0.12)
	tw.parallel().tween_property(self, "modulate:a", 0.0, 0.16)
	tw.tween_callback(queue_free)
