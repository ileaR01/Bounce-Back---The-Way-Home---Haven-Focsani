extends Area2D
class_name RetractableSpikes

@export var cycle_time: float = 2.8
@export var phase_offset: float = 0.0
@export var decorative_only: bool = false

var is_extended: bool = false
var is_warning: bool = false
var sprite: Sprite2D
var tex_extended: Texture2D
var tex_warning: Texture2D
var tex_retracted: Texture2D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2

	if ResourceLoader.exists("res://assets/elements/retractable_spikes_extended.svg"):
		tex_extended = load("res://assets/elements/retractable_spikes_extended.svg")
	if ResourceLoader.exists("res://assets/elements/retractable_spikes_warning.svg"):
		tex_warning = load("res://assets/elements/retractable_spikes_warning.svg")
	if ResourceLoader.exists("res://assets/elements/retractable_spikes_retracted.svg"):
		tex_retracted = load("res://assets/elements/retractable_spikes_retracted.svg")

	sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		add_child(sprite)
	sprite.position = Vector2(0, -14)
	sprite.texture = tex_extended if decorative_only else tex_retracted

	if not has_node("CollisionShape2D"):
		var col := CollisionShape2D.new()
		col.name = "CollisionShape2D"
		var rect := RectangleShape2D.new()
		rect.size = Vector2(46, 20)
		col.shape = rect
		col.position = Vector2(0, -10)
		add_child(col)
	body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	if decorative_only:
		is_extended = true
		is_warning = false
		return
	var t = fposmod(Time.get_ticks_msec() / 1000.0 + phase_offset, cycle_time)
	var ratio = t / cycle_time
	is_warning = (ratio >= 0.42 and ratio < 0.58)
	var newly_ext = (ratio >= 0.58)
	if newly_ext and not is_extended:
		is_extended = true
		for b in get_overlapping_bodies():
			_on_body_entered(b)
	else:
		is_extended = newly_ext

	if sprite:
		sprite.texture = tex_extended if is_extended else (tex_warning if is_warning else tex_retracted)

func _on_body_entered(body: Node2D) -> void:
	if decorative_only or not is_extended:
		return
	if body.is_in_group("player"):
		if has_node("/root/GameManager"):
			GameManager.take_damage(1)
		if body.has_method("apply_knockback"):
			body.apply_knockback(Vector2(0, -1.0), 380.0)
