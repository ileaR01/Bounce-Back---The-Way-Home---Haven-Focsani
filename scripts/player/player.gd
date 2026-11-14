extends CharacterBody2D
class_name Player

@export var speed: float = 275.0
@export var acceleration: float = 1450.0
@export var friction: float = 1450.0
@export var jump_velocity: float = -490.0
@export var gravity: float = 1100.0
@export var max_fall_speed: float = 900.0
@export var bounce_multiplier: float = 1.15

var coyote_time: float = 0.14
var coyote_timer: float = 0.0
var jump_buffer_time: float = 0.14
var jump_buffer_timer: float = 0.0

var is_bouncing: bool = false
var is_double_jumping: bool = false
var is_knocked_back: bool = false
var knockback_timer: float = 0.0
var can_bounce_recover: bool = false
var is_dead: bool = false
var is_in_wind: bool = false
var wind_vector: Vector2 = Vector2.ZERO
var can_double_jump: bool = true
var was_jump_key_down: bool = false
var is_gliding: bool = false
var is_teleporting: bool = false
var glide_sfx_timer: float = 0.0
var run_dust_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var camera: Camera2D = $Camera2D
@onready var recover_label: Label = $RecoverLabel

var tex_default: Texture2D
var tex_walk: Texture2D
var tex_jump: Texture2D

var base_scale: Vector2 = Vector2(0.35, 0.35)
var squash_tween: Tween

var shake_intensity: float = 0.0
var shake_timer: float = 0.0
var glide_wings_sprite: Sprite2D

func _ready() -> void:
	load_character_assets()
	glide_wings_sprite = Sprite2D.new()
	glide_wings_sprite.name = "GlideWingsSprite"
	if ResourceLoader.exists("res://assets/elements/player_glide_wings.svg"):
		glide_wings_sprite.texture = load("res://assets/elements/player_glide_wings.svg")
	glide_wings_sprite.position = Vector2(0, -36)
	glide_wings_sprite.visible = false
	add_child(glide_wings_sprite)
	move_child(glide_wings_sprite, 0)

	GameManager.player_damaged.connect(_on_damaged)
	GameManager.player_died.connect(_on_died)
	GameManager.player_respawned.connect(_on_respawned)

	if recover_label:
		recover_label.modulate.a = 0.0

func load_character_assets() -> void:
	var char_name = GameManager.current_character if has_node("/root/GameManager") else "boy"
	var folder = "res://assets/player/" + char_name + "/"

	tex_default = load(folder + "default.svg")
	tex_walk = load(folder + "walk1.svg")
	tex_jump = load(folder + "jump.svg")

	if sprite:
		sprite.texture = tex_default
		sprite.scale = base_scale

func _physics_process(delta: float) -> void:
	_process_camera_shake(delta)

	if is_teleporting:
		velocity = Vector2.ZERO
		return

	if is_dead:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.y += gravity * delta
		move_and_slide()
		return

	if DialogueManager.is_active:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		_update_animation(0)
		queue_redraw()
		return

	var input_x: float = 0.0
	if Input.is_action_pressed("move_left") or Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		input_x -= 1.0
	if Input.is_action_pressed("move_right") or Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		input_x += 1.0

	var raw_jump_down: bool = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	var jump_just_pressed: bool = Input.is_action_just_pressed("jump") or (raw_jump_down and not was_jump_key_down)
	var jump_released: bool = Input.is_action_just_released("jump") or (not raw_jump_down and was_jump_key_down)
	was_jump_key_down = raw_jump_down

	is_gliding = false
	if is_on_floor():
		coyote_timer = coyote_time
		is_bouncing = false
		is_double_jumping = false
		can_double_jump = true
		if is_knocked_back:
			can_bounce_recover = true
		if abs(velocity.x) > 90.0:
			run_dust_timer -= delta
			if run_dust_timer <= 0.0:
				run_dust_timer = 0.14
				_spawn_dust_puff(3, Color(0.85, 0.82, 0.78, 0.55))
	else:
		coyote_timer = max(0.0, coyote_timer - delta)
		if is_in_wind and wind_vector.y < 0.0:
			velocity.y = move_toward(velocity.y, wind_vector.y, 2800.0 * delta)
			is_bouncing = true
		else:
			var can_glide = has_node("/root/GameManager") and (GameManager.has_special_item("wind_feather") or GameManager.current_level_num >= 4)
			if can_glide and raw_jump_down and velocity.y > 40.0 and not is_knocked_back:
				is_gliding = true
				velocity.y = min(velocity.y + (gravity * 0.25) * delta, 145.0)
				glide_sfx_timer -= delta
				if glide_sfx_timer <= 0.0:
					glide_sfx_timer = 0.45
			else:
				velocity.y = min(velocity.y + gravity * delta, max_fall_speed)

	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta

	if knockback_timer > 0.0:
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			is_knocked_back = false
			can_bounce_recover = false

	if jump_just_pressed:
		if is_knocked_back or can_bounce_recover:
			bounce_back_recovery()
		elif is_in_wind:
			velocity.y = min(velocity.y, wind_vector.y * 1.25)
			can_double_jump = true
			apply_squash_stretch(Vector2(0.65, 1.4), 0.25)
		elif is_on_floor() or coyote_timer > 0.0:
			execute_jump()
		elif can_double_jump:
			execute_double_jump()
		else:
			jump_buffer_timer = jump_buffer_time

	if jump_buffer_timer > 0.0 and is_on_floor() and not is_knocked_back:
		execute_jump()

	if jump_released and velocity.y < (jump_velocity * 0.5) and not is_bouncing and not is_double_jumping:
		velocity.y = jump_velocity * 0.5

	if not is_knocked_back:
		if is_in_wind and abs(wind_vector.x) > 10.0:
			var wind_target_x = wind_vector.x + (input_x * speed * 0.85)
			velocity.x = move_toward(velocity.x, wind_target_x, 2400.0 * delta)
			if input_x != 0.0:
				sprite.flip_h = (input_x < 0.0)
		elif input_x != 0.0:
			var cur_speed = speed * (1.12 if is_gliding else 1.0)
			velocity.x = move_toward(velocity.x, input_x * cur_speed, acceleration * delta)
			sprite.flip_h = (input_x < 0.0)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, (friction * 0.4) * delta)

	var was_on_floor = is_on_floor()
	move_and_slide()

	if is_in_wind or is_gliding:
		sprite.rotation = lerpf(sprite.rotation, sin(Time.get_ticks_msec() * 0.015) * 0.14, 0.2)
	else:
		sprite.rotation = lerpf(sprite.rotation, 0.0, 0.2)

	is_in_wind = false
	wind_vector = Vector2.ZERO

	if not was_on_floor and is_on_floor() and velocity.y >= 0:
		apply_squash_stretch(Vector2(1.22, 0.78), 0.15)

	if glide_wings_sprite:
		glide_wings_sprite.visible = is_gliding
		if is_gliding:
			var t = Time.get_ticks_msec() / 1000.0
			glide_wings_sprite.position.y = -36.0 + sin(t * 14.0) * 3.0

	_update_animation(input_x)

func _spawn_dust_puff(_count: int, _col: Color) -> void:
	pass

func _spawn_bounce_burst(_is_super: bool) -> void:
	pass

func apply_wind(force: Vector2) -> void:
	is_in_wind = true
	wind_vector = force

func execute_jump() -> void:
	velocity.y = jump_velocity
	jump_buffer_timer = 0.0
	coyote_timer = 0.0
	is_double_jumping = false
	can_double_jump = true
	apply_squash_stretch(Vector2(0.8, 1.25), 0.2)
	_spawn_dust_puff(6, Color(0.9, 0.92, 1.0, 0.65))

func execute_double_jump() -> void:
	can_double_jump = false
	is_double_jumping = true
	jump_buffer_timer = 0.0
	coyote_timer = 0.0
	is_bouncing = false
	velocity.y = jump_velocity * 0.95
	apply_squash_stretch(Vector2(0.7, 1.35), 0.22)
	trigger_camera_shake(4.0, 0.15)
	_spawn_dust_puff(8, Color(0.45, 0.88, 1.0, 0.85))

func bounce(force: float, horizontal_boost: float = 0.0, is_super: bool = false) -> void:
	var relic_bonus = 1.08 if (has_node("/root/GameManager") and GameManager.has_special_item("bounce_crystal")) else 1.0
	velocity.y = - force * bounce_multiplier * relic_bonus
	if abs(horizontal_boost) > 0.1:
		velocity.x = horizontal_boost * bounce_multiplier
	is_bouncing = true
	is_knocked_back = false
	can_bounce_recover = false
	can_double_jump = true
	coyote_timer = 0.0
	jump_buffer_timer = 0.0

	_spawn_bounce_burst(is_super)
	if is_super:
		apply_squash_stretch(Vector2(0.5, 1.6), 0.38)
		trigger_camera_shake(14.0, 0.45)
	else:
		apply_squash_stretch(Vector2(0.6, 1.45), 0.3)
		trigger_camera_shake(8.0, 0.3)

	GameManager.trigger_bounce(force * bounce_multiplier)

func bounce_back_recovery() -> void:
	is_knocked_back = false
	can_bounce_recover = false
	can_double_jump = true
	knockback_timer = 0.0
	velocity.y = jump_velocity * 1.4
	var dir = -1.0 if sprite.flip_h else 1.0
	velocity.x = dir * speed * 1.35

	apply_squash_stretch(Vector2(0.65, 1.45), 0.3)
	trigger_camera_shake(9.0, 0.3)
	_spawn_bounce_burst(true)

func apply_knockback(dir: Vector2, force: float = 380.0) -> void:
	if GameManager.is_invulnerable or is_dead:
		return
	is_knocked_back = true
	can_bounce_recover = true
	knockback_timer = 0.6
	velocity = dir.normalized() * force
	velocity.y = min(velocity.y, -260.0)
	apply_squash_stretch(Vector2(1.2, 0.7), 0.2)
	trigger_camera_shake(10.0, 0.35)

func apply_squash_stretch(target_scale: Vector2, duration: float) -> void:
	if squash_tween and squash_tween.is_valid():
		squash_tween.kill()
	squash_tween = create_tween()
	var squashed = Vector2(base_scale.x * target_scale.x, base_scale.y * target_scale.y)
	squash_tween.tween_property(sprite, "scale", squashed, duration * 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	squash_tween.tween_property(sprite, "scale", base_scale, duration * 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func trigger_camera_shake(intensity: float, duration: float) -> void:
	shake_intensity = intensity
	shake_timer = duration

func _process_camera_shake(delta: float) -> void:
	if shake_timer > 0.0:
		shake_timer -= delta
		camera.offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		if shake_timer <= 0.0:
			camera.offset = Vector2.ZERO

func _update_animation(_input_x: float) -> void:
	if not is_on_floor():
		sprite.texture = tex_jump
	elif abs(velocity.x) > 20.0:
		var walk_cycle = int(Time.get_ticks_msec() / 150) % 2
		sprite.texture = tex_walk if walk_cycle == 1 else tex_default
	else:
		sprite.texture = tex_default

func _on_damaged() -> void:
	var flash_tween = create_tween().set_loops(4)
	flash_tween.tween_property(sprite, "modulate:a", 0.3, 0.1)
	flash_tween.tween_property(sprite, "modulate:a", 1.0, 0.1)

func _on_died() -> void:
	is_dead = true
	apply_squash_stretch(Vector2(1.3, 0.4), 0.3)

func _on_respawned() -> void:
	is_dead = false
	is_knocked_back = false
	can_bounce_recover = false
	velocity = Vector2.ZERO
	sprite.modulate = Color.WHITE
	sprite.scale = base_scale
	if GameManager.has_checkpoint:
		global_position = GameManager.active_checkpoint_pos
	else:
		var parent_lvl = get_parent()
		if parent_lvl and parent_lvl.has_node("SpawnPoint"):
			global_position = parent_lvl.get_node("SpawnPoint").global_position
	apply_squash_stretch(Vector2(0.8, 1.3), 0.3)
	_spawn_bounce_burst(true)
