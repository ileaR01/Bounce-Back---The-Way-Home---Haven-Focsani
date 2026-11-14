extends Node2D
class_name WorldDecor

@export_enum("torch", "statue", "glow_flora", "ruin_arch", "rune_clue", "cracked_wall_hint", "zone_banner", "water_hazard", "plant_hazard", "meadow_tree") var decor_type: String = "torch"
@export var label_text: String = ""
@export var sub_text: String = ""
@export var accent_color: Color = Color(0.85, 0.45, 1.0)
@export var enable_storm_on_enter: bool = false
@export var enable_sunset_on_enter: bool = false

var has_triggered_banner: bool = false
var phase_seed: float = 0.0
var sprite: Sprite2D

const DECOR_SVGS := {
	"torch": "res://assets/elements/decor_torch.svg",
	"statue": "res://assets/elements/decor_statue.svg",
	"glow_flora": "res://assets/elements/decor_glow_flora.svg",
	"ruin_arch": "res://assets/elements/decor_ruin_arch.svg",
	"rune_clue": "res://assets/elements/decor_rune_clue.svg",
	"cracked_wall_hint": "res://assets/elements/decor_cracked_wall.svg",
	"water_hazard": "res://assets/elements/decor_water_hazard.svg",
	"plant_hazard": "res://assets/elements/decor_plant_hazard.svg",
	"meadow_tree": "res://assets/elements/decor_meadow_tree.svg"
}

const DECOR_OFFSETS := {
	"torch": Vector2(0, -45),
	"statue": Vector2(0, -64),
	"glow_flora": Vector2(0, -30),
	"ruin_arch": Vector2(0, -68),
	"rune_clue": Vector2(0, -50),
	"cracked_wall_hint": Vector2(0, -54),
	"water_hazard": Vector2(0, -16),
	"plant_hazard": Vector2(0, -31),
	"meadow_tree": Vector2(0, -93)
}

func _ready() -> void:
	phase_seed = randf_range(0.0, TAU)

	if DECOR_SVGS.has(decor_type):
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		var svg_path: String = DECOR_SVGS[decor_type]
		if ResourceLoader.exists(svg_path):
			sprite.texture = load(svg_path)
		sprite.position = DECOR_OFFSETS.get(decor_type, Vector2(0, -32))
		add_child(sprite)

	if decor_type == "rune_clue" and (label_text != "" or sub_text != ""):
		var lbl := Label.new()
		lbl.position = Vector2(-64, -76)
		lbl.size = Vector2(128, 56)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", accent_color)
		lbl.text = label_text + ("\n" + sub_text if sub_text != "" else "")
		add_child(lbl)

	if decor_type in ["zone_banner", "water_hazard", "plant_hazard"]:
		var area := Area2D.new()
		area.collision_layer = 0
		area.collision_mask = 2
		var col := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		if decor_type == "zone_banner":
			rect.size = Vector2(90, 600)
			col.position = Vector2(0, -250)
		elif decor_type == "water_hazard":
			rect.size = Vector2(180, 28)
			col.position = Vector2(0, -14)
		else:
			rect.size = Vector2(36, 42)
			col.position = Vector2(0, -21)
		col.shape = rect
		area.add_child(col)
		add_child(area)
		area.body_entered.connect(_on_area_body_entered)

func _on_area_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if decor_type == "zone_banner" and not has_triggered_banner:
		has_triggered_banner = true
		if has_node("/root/GameManager") and label_text != "":
			GameManager.show_banner(label_text, sub_text, accent_color)
		var bg = get_tree().current_scene.get_node_or_null("ParallaxGarden") if get_tree() and get_tree().current_scene else null
		if bg:
			if enable_storm_on_enter:
				bg.storm_active = true
			if enable_sunset_on_enter:
				bg.sunset_meadow_blend = 1.0
	elif decor_type in ["water_hazard", "plant_hazard"]:
		if has_node("/root/GameManager"):
			GameManager.take_damage(1)
		if body.has_method("apply_knockback"):
			body.apply_knockback(Vector2(0, -1.0), 420.0)

func _process(_delta: float) -> void:
	if not sprite:
		return
	var t := Time.get_ticks_msec() / 1000.0 + phase_seed
	if decor_type in ["glow_flora", "meadow_tree", "plant_hazard"]:
		sprite.rotation = sin(t * 2.2) * 0.04
	elif decor_type == "torch":
		var s := 1.0 + sin(t * 8.0) * 0.03
		sprite.scale = Vector2(s, s)
