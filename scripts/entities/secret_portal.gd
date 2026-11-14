extends Area2D
class_name SecretPortal

@export var target_position: Vector2 = Vector2(6800, 460)
@export var banner_title: String = "AI DESCOPERIT SCURTĂTURA SECRETĂ!"
@export var banner_subtitle: String = "Uneori drumul care pare greșit este cel corect."
@export var unlock_gate_path: NodePath
@export var grant_emblem: bool = true

var player_in_range: Node2D = null
var is_activating: bool = false
var sprite: Sprite2D
var prompt_label: Label

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2

	sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		add_child(sprite)
	if ResourceLoader.exists("res://assets/elements/secret_portal.svg"):
		sprite.texture = load("res://assets/elements/secret_portal.svg")
	sprite.position = Vector2(0, -76)

	prompt_label = Label.new()
	prompt_label.position = Vector2(-115, -138)
	prompt_label.size = Vector2(230, 26)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 13)
	prompt_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55))
	prompt_label.text = "Apasă E pentru a interacționa"
	prompt_label.visible = false
	add_child(prompt_label)

	if not has_node("CollisionShape2D"):
		var col := CollisionShape2D.new()
		col.name = "CollisionShape2D"
		var cir := CircleShape2D.new()
		cir.radius = 65.0
		col.shape = cir
		col.position = Vector2(0, -48)
		add_child(col)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	var t: float = Time.get_ticks_msec() / 1000.0
	if sprite and not is_activating:
		var s: float = 1.0 + sin(t * 3.2) * 0.03
		sprite.scale = Vector2(s, s)
	if prompt_label:
		prompt_label.visible = (player_in_range != null and not is_activating)

func _unhandled_input(event: InputEvent) -> void:
	if not player_in_range or is_activating:
		return
	if has_node("/root/DialogueManager") and DialogueManager.is_active:
		return

	var pressed_e := false
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_E or event.physical_keycode == KEY_E or \
		   event.keycode == KEY_ENTER or event.physical_keycode == KEY_ENTER:
			pressed_e = true
	elif event.is_action_pressed("interact"):
		pressed_e = true

	if pressed_e:
		get_viewport().set_input_as_handled()
		activate_portal(player_in_range)

func activate_portal(player: Node2D) -> void:
	if is_activating or not player:
		return
	is_activating = true
	if "is_teleporting" in player:
		player.is_teleporting = true
	if "velocity" in player:
		player.velocity = Vector2.ZERO

	if grant_emblem and has_node("/root/GameManager"):
		GameManager.special_items["shadow_emblem"] = true
		GameManager.add_score(400)

	var tw = create_tween()
	if sprite:
		tw.tween_property(sprite, "scale", Vector2(1.25, 1.25), 0.38)
	tw.parallel().tween_property(player, "global_position", global_position + Vector2(0, -44), 0.38).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tw.finished

	var hud = get_tree().current_scene.get_node_or_null("HUD") if get_tree() and get_tree().current_scene else null
	if hud and hud.has_method("flash_screen"):
		hud.flash_screen(Color(0.55, 0.12, 0.85, 0.92), 0.85)

	player.global_position = target_position
	if "velocity" in player:
		player.velocity = Vector2.ZERO
	if "is_teleporting" in player:
		player.is_teleporting = false

	if unlock_gate_path:
		var g = get_node_or_null(unlock_gate_path)
		if g and g.has_method("unlock"):
			g.unlock()

	if has_node("/root/GameManager"):
		GameManager.set_checkpoint(target_position)
		GameManager.show_banner(banner_title, banner_subtitle, Color(0.92, 0.55, 1.0))

	if sprite:
		sprite.scale = Vector2.ONE
	is_activating = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = body

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null
