extends Area2D
class_name SpecialRelic

@export var relic_key: String = "bounce_crystal"
@export var relic_title: String = "CRISTALUL BOUNCE"
@export var relic_desc: String = "Îți amplifică săriturile elastice și deschide Poarta Sanctuarului!"

var start_y: float = 0.0
var is_collected: bool = false
var sprite: Sprite2D

const RELIC_SVGS := {
	"shadow_emblem": "res://assets/elements/relic_shadow_emblem.svg",
	"bounce_crystal": "res://assets/elements/relic_bounce_crystal.svg",
	"rune_heart": "res://assets/elements/relic_rune_heart.svg",
	"wind_feather": "res://assets/elements/relic_wind_feather.svg"
}

func _ready() -> void:
	start_y = position.y
	collision_layer = 0
	collision_mask = 2

	sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		add_child(sprite)
	var svg_path: String = RELIC_SVGS.get(relic_key, "res://assets/elements/relic_bounce_crystal.svg")
	if ResourceLoader.exists(svg_path):
		sprite.texture = load(svg_path)

	var lbl := Label.new()
	lbl.position = Vector2(-80, -48)
	lbl.size = Vector2(160, 20)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
	lbl.text = relic_title
	add_child(lbl)

	if not has_node("CollisionShape2D"):
		var col := CollisionShape2D.new()
		col.name = "CollisionShape2D"
		var cir := CircleShape2D.new()
		cir.radius = 28.0
		col.shape = cir
		add_child(col)
	body_entered.connect(_on_body_entered)

func _process(_delta: float) -> void:
	if is_collected:
		return
	var t = Time.get_ticks_msec() / 1000.0
	position.y = start_y + sin(t * 2.6) * 8.0

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	if body.is_in_group("player"):
		is_collected = true
		if has_node("/root/GameManager"):
			GameManager.unlock_special_item(relic_key)
			GameManager.show_banner(relic_title, relic_desc, Color(1.0, 0.9, 0.35))

		var tw = create_tween()
		tw.tween_property(self, "scale", Vector2(1.8, 1.8), 0.25)
		tw.parallel().tween_property(self, "modulate:a", 0.0, 0.25)
		tw.tween_callback(queue_free)
