extends CharacterBody2D
class_name ShadowGuardianEnemy

@export var speed: float = 55.0
@export var patrol_range: float = 110.0
@export var shoot_interval: float = 3.2
@export var max_hp: int = 2

var start_x: float = 0.0
var direction: float = -1.0
var hp: int = 2
var is_defeated: bool = false
var shoot_timer: float = 1.6
var projectiles: Array[Dictionary] = []
var sprite: Sprite2D
var proj_tex: Texture2D

func _ready() -> void:
	start_x = global_position.x
	hp = max_hp
	collision_layer = 4
	collision_mask = 1

	if ResourceLoader.exists("res://assets/elements/shadow_projectile.svg"):
		proj_tex = load("res://assets/elements/shadow_projectile.svg")

	sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		add_child(sprite)
	if ResourceLoader.exists("res://assets/elements/enemy_shadow_guardian.svg"):
		sprite.texture = load("res://assets/elements/enemy_shadow_guardian.svg")
	sprite.position = Vector2(0, -30)

	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(36, 52)
	col.shape = rect
	col.position = Vector2(0, -26)
	add_child(col)

	var hitbox := Area2D.new()
	hitbox.collision_layer = 0
	hitbox.collision_mask = 2
	var hcol := CollisionShape2D.new()
	var hrect := RectangleShape2D.new()
	hrect.size = Vector2(40, 34)
	hcol.shape = hrect
	hcol.position = Vector2(0, -18)
	hitbox.add_child(hcol)
	add_child(hitbox)
	hitbox.body_entered.connect(_on_hitbox_entered)

	var hurtbox := Area2D.new()
	hurtbox.collision_layer = 0
	hurtbox.collision_mask = 2
	var ucol := CollisionShape2D.new()
	var urect := RectangleShape2D.new()
	urect.size = Vector2(42, 20)
	ucol.shape = urect
	ucol.position = Vector2(0, -48)
	hurtbox.add_child(ucol)
	add_child(hurtbox)
	hurtbox.body_entered.connect(_on_hurtbox_entered)

func _physics_process(delta: float) -> void:
	if is_defeated:
		return
	if global_position.x > start_x + patrol_range:
		direction = -1.0
	elif global_position.x < start_x - patrol_range:
		direction = 1.0
	if sprite:
		sprite.flip_h = (direction > 0.0)
	velocity.x = direction * speed
	velocity.y = 240.0
	move_and_slide()

	shoot_timer -= delta
	if shoot_timer <= 0.0:
		shoot_timer = shoot_interval
		_spawn_projectile()

	_update_projectiles(delta)

func _spawn_projectile() -> void:
	var p_sp := Sprite2D.new()
	p_sp.texture = proj_tex
	p_sp.position = Vector2(direction * 22.0, -28.0)
	add_child(p_sp)
	projectiles.append({
		"pos": Vector2(direction * 22.0, -28.0),
		"vel": Vector2(direction * 210.0, 0.0),
		"age": 0.0,
		"life": 1.8,
		"sprite": p_sp
	})

func _update_projectiles(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player") if get_tree() else null
	var i = projectiles.size() - 1
	while i >= 0:
		var p = projectiles[i]
		p["age"] += delta
		p["pos"] += p["vel"] * delta
		var p_sp: Sprite2D = p["sprite"]
		if is_instance_valid(p_sp):
			p_sp.position = p["pos"]
		var world_p: Vector2 = global_position + p["pos"]
		if player and world_p.distance_to(player.global_position + Vector2(0, -28)) < 22.0:
			if has_node("/root/GameManager"):
				GameManager.take_damage(1)
			if player.has_method("apply_knockback"):
				player.apply_knockback(Vector2(sign(p["vel"].x), -0.6), 360.0)
			if is_instance_valid(p_sp):
				p_sp.queue_free()
			projectiles.remove_at(i)
		elif p["age"] >= p["life"]:
			if is_instance_valid(p_sp):
				p_sp.queue_free()
			projectiles.remove_at(i)
		i -= 1

func _on_hurtbox_entered(body: Node2D) -> void:
	if is_defeated:
		return
	if body.is_in_group("player") and body.velocity.y >= -60.0:
		hp -= 1

		if body.has_method("bounce"):
			body.bounce(700.0, 0.0, hp <= 0)

		if hp <= 0:
			is_defeated = true
			if has_node("/root/GameManager"):
				GameManager.add_score(200)
			var tw = create_tween()
			tw.tween_property(self, "scale", Vector2(1.4, 0.2), 0.16)
			tw.parallel().tween_property(self, "modulate:a", 0.0, 0.18)
			tw.tween_callback(queue_free)

func _on_hitbox_entered(body: Node2D) -> void:
	if is_defeated:
		return
	if body.is_in_group("player") and body.global_position.y > global_position.y - 36.0:
		if has_node("/root/GameManager"):
			GameManager.take_damage(1)
		if body.has_method("apply_knockback"):
			body.apply_knockback(Vector2(direction, -0.6), 380.0)
