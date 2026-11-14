extends Area2D

@export var wind_force: Vector2 = Vector2(0, -620.0)
@export var zone_width: float = 240.0
@export var zone_height: float = 320.0

@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
var bodies_inside: Array[Node2D] = []
var sprite: Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		add_child(sprite)
	if ResourceLoader.exists("res://assets/elements/wind_current.svg"):
		sprite.texture = load("res://assets/elements/wind_current.svg")
	if sprite.texture:
		var tsize := sprite.texture.get_size()
		if tsize.x > 0 and tsize.y > 0:
			sprite.scale = Vector2(zone_width / tsize.x, zone_height / tsize.y)

	if collision_shape:
		var rect = RectangleShape2D.new()
		rect.size = Vector2(zone_width, zone_height)
		collision_shape.shape = rect

func _physics_process(delta: float) -> void:
	for b in bodies_inside:
		if b.is_in_group("player") and b.has_method("apply_wind"):
			b.apply_wind(wind_force)
		elif "velocity" in b:
			b.velocity += wind_force * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not bodies_inside.has(body):
			bodies_inside.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		bodies_inside.erase(body)
