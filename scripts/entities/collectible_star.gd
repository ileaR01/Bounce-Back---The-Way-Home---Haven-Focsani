extends Area2D
class_name CollectibleStar

@export var star_id: String = "star_1"
var start_y: float = 0.0
var time_offset: float = 0.0
var is_collected: bool = false
var sprite: Sprite2D

func _ready() -> void:
	start_y = position.y
	time_offset = randf_range(0.0, TAU)
	collision_layer = 0
	collision_mask = 2

	sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		add_child(sprite)
	if ResourceLoader.exists("res://assets/elements/collectible_star.svg"):
		sprite.texture = load("res://assets/elements/collectible_star.svg")

	if not has_node("CollisionShape2D"):
		var col := CollisionShape2D.new()
		col.name = "CollisionShape2D"
		var cir := CircleShape2D.new()
		cir.radius = 24.0
		col.shape = cir
		add_child(col)

	body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	if is_collected:
		return
	var t = Time.get_ticks_msec() / 1000.0 + time_offset
	position.y = start_y + sin(t * 3.0) * 7.0
	if sprite:
		sprite.rotation = sin(t * 2.0) * 0.2

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	if body.is_in_group("player"):
		is_collected = true
		if has_node("/root/GameManager"):
			GameManager.collect_star()

		var tw = create_tween()
		tw.tween_property(self, "scale", Vector2(1.6, 1.6), 0.18)
		tw.parallel().tween_property(self, "modulate:a", 0.0, 0.22)
		tw.tween_callback(queue_free)
