extends Area2D
class_name AlternatingWindZone

@export var force_a: Vector2 = Vector2(220, -480)
@export var force_b: Vector2 = Vector2(-140, -520)
@export var switch_interval: float = 3.6
@export var zone_width: float = 280.0
@export var zone_height: float = 340.0

var current_force: Vector2 = Vector2.ZERO
var bodies_inside: Array[Node2D] = []
var wind_sprite: Sprite2D
var arrow_sprite: Sprite2D

func _ready() -> void:
	current_force = force_a
	collision_layer = 0
	collision_mask = 2

	wind_sprite = Sprite2D.new()
	wind_sprite.name = "WindSprite"
	if ResourceLoader.exists("res://assets/elements/wind_current.svg"):
		wind_sprite.texture = load("res://assets/elements/wind_current.svg")
	if wind_sprite.texture:
		var tsize := wind_sprite.texture.get_size()
		if tsize.x > 0 and tsize.y > 0:
			wind_sprite.scale = Vector2(zone_width / tsize.x, zone_height / tsize.y)
	add_child(wind_sprite)

	arrow_sprite = Sprite2D.new()
	arrow_sprite.name = "ArrowSprite"
	if ResourceLoader.exists("res://assets/elements/wind_arrow.svg"):
		arrow_sprite.texture = load("res://assets/elements/wind_arrow.svg")
	arrow_sprite.position = Vector2(0, -zone_height * 0.42)
	add_child(arrow_sprite)

	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(zone_width, zone_height)
	col.shape = rect
	add_child(col)

	body_entered.connect(func(b):
		if b.is_in_group("player") and not bodies_inside.has(b):
			bodies_inside.append(b)
	)
	body_exited.connect(func(b):
		bodies_inside.erase(b)
	)

func _physics_process(_delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var cycle := int(t / switch_interval) % 2
	current_force = force_a if cycle == 0 else force_b

	if arrow_sprite:
		arrow_sprite.rotation = current_force.angle()

	for b in bodies_inside:
		if b.is_in_group("player") and b.has_method("apply_wind"):
			b.apply_wind(current_force)
