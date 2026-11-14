extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
var start_y: float = 0.0
var time_offset: float = 0.0
var is_collected: bool = false

func _ready() -> void:
	start_y = position.y
	time_offset = randf_range(0.0, 5.0)
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if is_collected:
		return
	var t = Time.get_ticks_msec() / 1000.0 + time_offset
	position.y = start_y + sin(t * 3.5) * 6.0
	if sprite:
		sprite.rotation = sin(t * 2.0) * 0.15

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	if body.is_in_group("player"):
		is_collected = true
		if has_node("/root/GameManager"):
			GameManager.collect_seed()
		var tw = create_tween()
		if sprite:
			tw.parallel().tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.15)
			tw.parallel().tween_property(sprite, "modulate:a", 0.0, 0.2)
		tw.parallel().tween_property(self, "position:y", position.y - 25.0, 0.2)
		tw.tween_callback(queue_free)
