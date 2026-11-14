extends ParallaxBackground
class_name ThemedParallax

@export var override_level: int = 0

var storm_active: bool = false
var sunset_meadow_blend: float = 0.0

const BG_TEXTURE_PATH := "res://assets/backgroundGame.jpg"

func _ready() -> void:
	var bg_tex: Texture2D = load(BG_TEXTURE_PATH) if ResourceLoader.exists(BG_TEXTURE_PATH) else null

	for child in get_children():
		if child is ParallaxLayer:
			for sub in child.get_children():
				if sub is Sprite2D:
					if child.name == "SkyLayer":
						sub.visible = true
						if bg_tex:
							sub.texture = bg_tex
							sub.position = Vector2(640, 360)
							var tex_size := bg_tex.get_size()
							if tex_size.x > 0 and tex_size.y > 0:
								sub.scale = Vector2(1280.0 / tex_size.x, 720.0 / tex_size.y)
					else:
						sub.visible = false

	var sky_layer := get_node_or_null("SkyLayer") as ParallaxLayer
	if not sky_layer:
		sky_layer = ParallaxLayer.new()
		sky_layer.name = "SkyLayer"
		sky_layer.motion_scale = Vector2(0.0, 0.0)
		add_child(sky_layer)
		if bg_tex:
			var sp := Sprite2D.new()
			sp.name = "Sprite2D"
			sp.texture = bg_tex
			sp.position = Vector2(640, 360)
			var tex_size := bg_tex.get_size()
			if tex_size.x > 0 and tex_size.y > 0:
				sp.scale = Vector2(1280.0 / tex_size.x, 720.0 / tex_size.y)
			sky_layer.add_child(sp)
