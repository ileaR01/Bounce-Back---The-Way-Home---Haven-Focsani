extends Area2D
class_name LightningHazard

@export var strike_interval: float = 4.2
@export var phase_offset: float = 0.0
@export var beam_height: float = 360.0

var state: int = 0
var played_thunder: bool = false
var sprite: Sprite2D
var tex_warning: Texture2D
var tex_bolt: Texture2D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2

	if ResourceLoader.exists("res://assets/elements/lightning_warning.svg"):
		tex_warning = load("res://assets/elements/lightning_warning.svg")
	if ResourceLoader.exists("res://assets/elements/lightning_bolt.svg"):
		tex_bolt = load("res://assets/elements/lightning_bolt.svg")

	sprite = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.position = Vector2(0, -beam_height * 0.5)
	sprite.visible = false
	add_child(sprite)

	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(28, beam_height)
	col.shape = rect
	col.position = Vector2(0, -beam_height * 0.5)
	add_child(col)
	body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	var t := fposmod(Time.get_ticks_msec() / 1000.0 + phase_offset, strike_interval)
	if t < strike_interval - 1.55:
		state = 0
		played_thunder = false
		if sprite:
			sprite.visible = false
	elif t < strike_interval - 0.35:
		state = 1
		if sprite:
			sprite.visible = true
			sprite.texture = tex_warning
	else:
		if state != 2:
			state = 2
			if not played_thunder:
				played_thunder = true
			for b in get_overlapping_bodies():
				_on_body_entered(b)
		if sprite:
			sprite.visible = true
			sprite.texture = tex_bolt

func _on_body_entered(body: Node2D) -> void:
	if state != 2:
		return
	if body.is_in_group("player"):
		if has_node("/root/GameManager"):
			GameManager.take_damage(1)
		if body.has_method("apply_knockback"):
			body.apply_knockback(Vector2(-1.0, -0.7), 400.0)
