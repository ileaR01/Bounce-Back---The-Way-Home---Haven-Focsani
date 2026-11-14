extends StaticBody2D
class_name ThemedPlatform

@export var platform_type: String = "auto"
@export var custom_width: float = 160.0
@export var custom_height: float = 48.0
@export var has_decor: bool = true

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var col_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

var resolved_style: String = "shadow_stone"

const PLATFORM_SVGS := {
	"shadow_stone": "res://assets/elements/platform_shadow_stone.svg",
	"abyss_root": "res://assets/elements/platform_abyss_root.svg",
	"rune_temple": "res://assets/elements/platform_rune_temple.svg",
	"canyon_rock": "res://assets/elements/platform_canyon_rock.svg",
	"golden_sanctuary": "res://assets/elements/platform_golden_sanctuary.svg",
	"meadow_grass": "res://assets/elements/platform_meadow_grass.svg"
}

func _ready() -> void:
	if col_shape:
		var rect := RectangleShape2D.new()
		rect.size = Vector2(custom_width, custom_height)
		col_shape.shape = rect
		col_shape.position = Vector2(0, -custom_height * 0.5)
	_resolve_style()
	_apply_svg_sprite()

func _resolve_style() -> void:
	if platform_type != "auto" and platform_type != "grass" and platform_type != "wood":
		resolved_style = platform_type
	else:
		var lvl: int = GameManager.current_level_num if has_node("/root/GameManager") else 1
		match lvl:
			1: resolved_style = "shadow_stone"
			2: resolved_style = "abyss_root"
			3: resolved_style = "rune_temple"
			4: resolved_style = "canyon_rock"
			5: resolved_style = "golden_sanctuary"
			_: resolved_style = "shadow_stone"
	if platform_type == "meadow":
		resolved_style = "meadow_grass"

func _apply_svg_sprite() -> void:
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		add_child(sprite)
	sprite.visible = true
	var svg_path: String = PLATFORM_SVGS.get(resolved_style, "res://assets/elements/platform_shadow_stone.svg")
	if ResourceLoader.exists(svg_path):
		sprite.texture = load(svg_path)
	sprite.position = Vector2(0, -custom_height * 0.5)
	if sprite.texture:
		var tsize := sprite.texture.get_size()
		if tsize.x > 0 and tsize.y > 0:
			sprite.scale = Vector2(custom_width / tsize.x, custom_height / tsize.y)
