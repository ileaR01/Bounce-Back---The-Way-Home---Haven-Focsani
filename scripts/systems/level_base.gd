extends Node2D
class_name LevelBase

@export var level_number: int = 1
@export var level_width: float = 9600.0
@export var fall_death_y: float = 1050.0
@export var camera_top_limit: int = -850

@onready var player: Player = $Player
@onready var spawn_point: Marker2D = $SpawnPoint

const SCN_PLATFORM = preload("res://scenes/environment/platform.tscn")
const SCN_CRUMBLING = preload("res://scenes/entities/crumbling_platform.tscn")
const SCN_MOVING = preload("res://scenes/entities/moving_platform.tscn")
const SCN_SPIKES = preload("res://scenes/entities/hazard_spikes.tscn")
const SCN_SEED = preload("res://scenes/entities/collectible_seed.tscn")
const SCN_CHECKPOINT = preload("res://scenes/entities/checkpoint.tscn")
const SCN_FLOWER = preload("res://scenes/entities/bounce_flower.tscn")
const SCN_SUPER_MUSH = preload("res://scenes/entities/super_mushroom.tscn")
const SCN_GATE = preload("res://scenes/entities/rune_gate.tscn")
const SCN_SWITCH = preload("res://scenes/entities/puzzle_switch.tscn")
const SCN_WIND = preload("res://scenes/entities/wind_zone.tscn")
const SCN_EXIT = preload("res://scenes/entities/level_exit.tscn")
const SCN_COTTAGE = preload("res://scenes/entities/home_cottage.tscn")
const SCN_CATERPILLAR = preload("res://scenes/enemies/enemy_caterpillar.tscn")
const SCN_SNAIL = preload("res://scenes/enemies/enemy_snail.tscn")
const SCN_BEE = preload("res://scenes/enemies/enemy_bee.tscn")
const SCN_NPC_BUTTERFLY = preload("res://scenes/npcs/npc_butterfly.tscn")
const SCN_NPC_RABBIT = preload("res://scenes/npcs/npc_rabbit.tscn")
const SCN_NPC_TURTLE = preload("res://scenes/npcs/npc_turtle.tscn")

func _ready() -> void:
	if has_node("/root/GameManager"):
		GameManager.start_level(level_number)

	_clear_legacy_level_nodes()
	_build_level()

	if player:
		if has_node("/root/GameManager") and GameManager.has_checkpoint:
			player.global_position = GameManager.active_checkpoint_pos
		elif spawn_point:
			player.global_position = spawn_point.global_position

		if player.camera:
			player.camera.limit_left = 0
			player.camera.limit_top = camera_top_limit
			player.camera.limit_bottom = int(fall_death_y + 100)
			player.camera.limit_right = int(level_width)

func _clear_legacy_level_nodes() -> void:
	var keep_names = ["ParallaxGarden", "HUD", "DialogueBox", "SpawnPoint", "Player"]
	for c in get_children():
		if not (c.name in keep_names):
			c.queue_free()

func _build_level() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if player and player.global_position.y > fall_death_y:
		_handle_player_fall()

func _handle_player_fall() -> void:
	if GameManager.is_invulnerable or player.is_dead:
		return
	GameManager.take_damage(1)
	if player and not player.is_dead and GameManager.current_health > 0:
		player.velocity = Vector2.ZERO
		if GameManager.has_checkpoint:
			player.global_position = GameManager.active_checkpoint_pos
		elif spawn_point:
			player.global_position = spawn_point.global_position
		player.bounce(500.0, 0.0, false)

func add_platform(pos: Vector2, width: float = 160.0, height: float = 48.0, ptype: String = "auto") -> StaticBody2D:
	var p: StaticBody2D = SCN_PLATFORM.instantiate()
	p.position = pos
	p.set("custom_width", width)
	p.set("custom_height", height)
	p.set("platform_type", ptype)
	add_child(p)
	return p

func add_ground_run(start_x: float, y: float, count: int, step: float = 160.0, ptype: String = "auto") -> void:
	for i in range(count):
		add_platform(Vector2(start_x + i * step, y), step, 56.0, ptype)

func add_crumbling(pos: Vector2, delay: float = 0.42) -> Node2D:
	var c = SCN_CRUMBLING.instantiate()
	c.position = pos
	c.crumble_delay = delay
	add_child(c)
	return c

func add_moving_platform(pos: Vector2, offset: Vector2, duration: float = 2.8) -> Node2D:
	var m = SCN_MOVING.instantiate()
	m.position = pos
	m.move_offset = offset
	m.move_duration = duration
	add_child(m)
	return m

func add_spikes(pos: Vector2) -> Node2D:
	var s = SCN_SPIKES.instantiate()
	s.position = pos
	add_child(s)
	return s

func add_retractable_spikes(pos: Vector2, cycle: float = 2.8, phase_off: float = 0.0, decor_only: bool = false) -> RetractableSpikes:
	var rs := RetractableSpikes.new()
	rs.position = pos
	rs.cycle_time = cycle
	rs.phase_offset = phase_off
	rs.decorative_only = decor_only
	add_child(rs)
	return rs

func add_blade(pos: Vector2, offset: Vector2, duration: float = 2.2) -> MovingBlade:
	var b := MovingBlade.new()
	b.position = pos
	b.move_offset = offset
	b.move_duration = duration
	add_child(b)
	return b

func add_crate(pos: Vector2, coins: int = 2) -> BreakableCrate:
	var cr := BreakableCrate.new()
	cr.position = pos
	cr.coins_inside = coins
	add_child(cr)
	return cr

func add_coin(pos: Vector2) -> Node2D:
	var s = SCN_SEED.instantiate()
	s.position = pos
	add_child(s)
	return s

func add_coin_row(start_pos: Vector2, count: int, spacing: float = 48.0, arc_h: float = 0.0) -> void:
	for i in range(count):
		var ratio: float = float(i) / float(max(1, count - 1)) if count > 1 else 0.0
		var y_off: float = - sin(ratio * PI) * arc_h
		add_coin(start_pos + Vector2(i * spacing, y_off))

func add_star(pos: Vector2, id_str: String = "star") -> CollectibleStar:
	var st := CollectibleStar.new()
	st.position = pos
	st.star_id = id_str
	add_child(st)
	return st

func add_relic(pos: Vector2, key: String, title: String, desc: String) -> SpecialRelic:
	var r := SpecialRelic.new()
	r.position = pos
	r.relic_key = key
	r.relic_title = title
	r.relic_desc = desc
	add_child(r)
	return r

func add_checkpoint(pos: Vector2) -> Node2D:
	var cp = SCN_CHECKPOINT.instantiate()
	cp.position = pos
	add_child(cp)
	return cp

func add_flower(pos: Vector2, force: float = 680.0) -> Node2D:
	var f = SCN_FLOWER.instantiate()
	f.position = pos
	f.bounce_force = force
	add_child(f)
	return f

func add_mushroom(pos: Vector2, mtype: String = "medium", force: float = 820.0, h_boost: float = 0.0, move_off: Vector2 = Vector2.ZERO) -> BounceMushroom:
	var m := BounceMushroom.new()
	m.position = pos
	m.mushroom_type = mtype
	m.bounce_force = force
	m.horizontal_boost = h_boost
	if move_off != Vector2.ZERO:
		m.move_offset = move_off
	add_child(m)
	return m

func add_wind(pos: Vector2, force: Vector2, w: float = 240.0, h: float = 320.0) -> Node2D:
	var wz = SCN_WIND.instantiate()
	wz.position = pos
	wz.wind_force = force
	wz.zone_width = w
	wz.zone_height = h
	add_child(wz)
	return wz

func add_alt_wind(pos: Vector2, fa: Vector2, fb: Vector2, interval: float = 3.5, w: float = 260.0, h: float = 320.0) -> AlternatingWindZone:
	var aw := AlternatingWindZone.new()
	aw.position = pos
	aw.force_a = fa
	aw.force_b = fb
	aw.switch_interval = interval
	aw.zone_width = w
	aw.zone_height = h
	add_child(aw)
	return aw

func add_falling_rock(pos: Vector2, drop_dist: float = 320.0, cycle: float = 3.4, phase_off: float = 0.0) -> FallingRockHazard:
	var fr := FallingRockHazard.new()
	fr.position = pos
	fr.drop_distance = drop_dist
	fr.cycle_duration = cycle
	fr.phase_offset = phase_off
	add_child(fr)
	return fr

func add_lightning(pos: Vector2, interval: float = 4.0, phase_off: float = 0.0, height: float = 360.0) -> LightningHazard:
	var lh := LightningHazard.new()
	lh.position = pos
	lh.strike_interval = interval
	lh.phase_offset = phase_off
	lh.beam_height = height
	add_child(lh)
	return lh

func add_enemy_caterpillar(pos: Vector2, prange: float = 90.0, spd: float = 55.0) -> Node2D:
	var e = SCN_CATERPILLAR.instantiate()
	e.position = pos
	e.patrol_range = prange
	e.speed = spd
	add_child(e)
	return e

func add_enemy_snail(pos: Vector2, prange: float = 80.0, spd: float = 40.0) -> Node2D:
	var e = SCN_SNAIL.instantiate()
	e.position = pos
	e.patrol_range = prange
	e.speed = spd
	add_child(e)
	return e

func add_enemy_bee(pos: Vector2, prange: float = 110.0, spd: float = 70.0) -> Node2D:
	var e = SCN_BEE.instantiate()
	e.position = pos
	e.patrol_range = prange
	e.speed = spd
	add_child(e)
	return e

func add_enemy_guardian(pos: Vector2, prange: float = 100.0) -> ShadowGuardianEnemy:
	var g := ShadowGuardianEnemy.new()
	g.position = pos
	g.patrol_range = prange
	add_child(g)
	return g

func add_npc(pos: Vector2, npc_name_str: String, avatar_str: String, vtype: String, lines: Array[String], repeat_lines: Array[String] = [], auto_trig: bool = false, vanish: bool = false, grant_item: String = "") -> NPCBase:
	var base_scn = SCN_NPC_BUTTERFLY
	if vtype == "rabbit":
		base_scn = SCN_NPC_RABBIT
	elif vtype == "turtle":
		base_scn = SCN_NPC_TURTLE
	var n: NPCBase = base_scn.instantiate()
	n.position = pos
	n.npc_name = npc_name_str
	n.avatar_key = avatar_str
	n.npc_visual_type = vtype
	n.dialogue_lines = lines
	n.repeat_dialogue_lines = repeat_lines
	n.auto_trigger = auto_trig
	n.vanish_after_dialogue = vanish
	n.grant_special_item_on_finish = grant_item
	add_child(n)
	return n

func add_gate(pos: Vector2, node_name: String = "RuneGate") -> Node2D:
	var g = SCN_GATE.instantiate()
	g.name = node_name
	g.position = pos
	add_child(g)
	return g

func add_switch(pos: Vector2, gate_node: Node2D) -> Node2D:
	var sw = SCN_SWITCH.instantiate()
	sw.position = pos
	add_child(sw)
	if gate_node:
		sw.target_gate = sw.get_path_to(gate_node)
	return sw

func add_decor(pos: Vector2, dtype: String, text_str: String = "", sub_str: String = "", col: Color = Color(0.85, 0.45, 1.0)) -> WorldDecor:
	var d := WorldDecor.new()
	d.position = pos
	d.decor_type = dtype
	d.label_text = text_str
	d.sub_text = sub_str
	d.accent_color = col
	add_child(d)
	return d

func add_exit(pos: Vector2) -> Node2D:
	var ex = SCN_EXIT.instantiate()
	ex.position = pos
	add_child(ex)
	return ex

func add_cottage(pos: Vector2) -> Node2D:
	var cot = SCN_COTTAGE.instantiate()
	cot.position = pos
	add_child(cot)
	return cot
