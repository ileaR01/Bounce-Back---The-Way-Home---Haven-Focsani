extends Area2D
class_name FallingRockHazard

@export var drop_distance: float = 340.0
@export var cycle_duration: float = 3.6
@export var phase_offset: float = 0.0

var start_y: float = 0.0
var state: int = 0
var sprite: Sprite2D

func _ready() -> void:
	start_y = position.y
	collision_layer = 0
	collision_mask = 2

	sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		add_child(sprite)
	if ResourceLoader.exists("res://assets/elements/falling_rock.svg"):
		sprite.texture = load("res://assets/elements/falling_rock.svg")

	var col := CollisionShape2D.new()
	var cir := CircleShape2D.new()
	cir.radius = 18.0
	col.shape = cir
	add_child(col)
	body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	var t := fposmod(Time.get_ticks_msec() / 1000.0 + phase_offset, cycle_duration)
	var ratio := t / cycle_duration
	if ratio < 0.35:
		state = 0
		position.y = start_y
		if sprite:
			sprite.modulate = Color.WHITE
	elif ratio < 0.62:
		state = 1
		position.y = start_y + sin(t * 45.0) * 3.0
		if sprite:
			sprite.modulate = Color(1.0, 0.72, 0.55)
	else:
		state = 2
		var fall_r := (ratio - 0.62) / 0.38
		position.y = start_y + fall_r * drop_distance
		if sprite:
			sprite.modulate = Color.WHITE

func _on_body_entered(body: Node2D) -> void:
	if state == 0:
		return
	if body.is_in_group("player"):
		if has_node("/root/GameManager"):
			GameManager.take_damage(1)
		if body.has_method("apply_knockback"):
			body.apply_knockback(Vector2(-1.0, -0.6), 360.0)
