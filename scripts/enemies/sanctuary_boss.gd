extends Node2D
class_name SanctuaryBossEncounter

@export var target_gate: NodePath

var phase: int = 1
var guardian_pos: Vector2 = Vector2(0, -160)
var attack_timer: float = 2.2
var is_telegraphing: bool = false
var orbs: Array[Dictionary] = []
var gate_open_progress: float = 0.0
var is_cinematic_playing: bool = false

var boss_sprite: Sprite2D
var seal_sprite: Sprite2D
var seal_label: Label
var portal_entry_sprite: Sprite2D
var portal_exit_sprite: Sprite2D
var proj_tex: Texture2D

const SEAL_POSITIONS = {
	1: Vector2(-170, -145),
	2: Vector2(185, -215),
	3: Vector2(0, -255)
}
const PORTAL_ENTRY_POS = Vector2(-210, -45)
const PORTAL_EXIT_POS = Vector2(-50, -245)

func _ready() -> void:
	if ResourceLoader.exists("res://assets/elements/shadow_projectile.svg"):
		proj_tex = load("res://assets/elements/shadow_projectile.svg")

	boss_sprite = get_node_or_null("Sprite2D")
	if not boss_sprite:
		boss_sprite = Sprite2D.new()
		boss_sprite.name = "BossSprite"
		add_child(boss_sprite)
	if ResourceLoader.exists("res://assets/elements/npc_guardian.svg"):
		boss_sprite.texture = load("res://assets/elements/npc_guardian.svg")
	boss_sprite.position = guardian_pos

	seal_sprite = Sprite2D.new()
	seal_sprite.name = "SealSprite"
	if ResourceLoader.exists("res://assets/elements/boss_resonance_seal.svg"):
		seal_sprite.texture = load("res://assets/elements/boss_resonance_seal.svg")
	seal_sprite.position = SEAL_POSITIONS[1]
	add_child(seal_sprite)

	seal_label = Label.new()
	seal_label.position = SEAL_POSITIONS[1] + Vector2(-65, -48)
	seal_label.size = Vector2(130, 20)
	seal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	seal_label.add_theme_font_size_override("font_size", 12)
	seal_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.55))
	seal_label.text = "SIGILIUL FAZEI 1"
	add_child(seal_label)

	portal_entry_sprite = Sprite2D.new()
	portal_entry_sprite.position = PORTAL_ENTRY_POS
	if ResourceLoader.exists("res://assets/elements/boss_runic_portal.svg"):
		portal_entry_sprite.texture = load("res://assets/elements/boss_runic_portal.svg")
	portal_entry_sprite.visible = false
	add_child(portal_entry_sprite)

	portal_exit_sprite = Sprite2D.new()
	portal_exit_sprite.position = PORTAL_EXIT_POS
	if ResourceLoader.exists("res://assets/elements/boss_runic_portal.svg"):
		portal_exit_sprite.texture = load("res://assets/elements/boss_runic_portal.svg")
	portal_exit_sprite.visible = false
	add_child(portal_exit_sprite)

func _physics_process(delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var player := get_tree().get_first_node_in_group("player") if get_tree() else null

	if phase <= 3:
		guardian_pos = Vector2(sin(t * 1.4) * 110.0, -165.0 + cos(t * 2.2) * 18.0)
		if player and abs(player.global_position.x - global_position.x) < 520.0:
			_process_boss_phase(delta, player)
	else:
		guardian_pos = guardian_pos.lerp(Vector2(250, -75), delta * 2.5)

	if boss_sprite:
		boss_sprite.position = guardian_pos
	if seal_sprite:
		seal_sprite.visible = (phase <= 3)
		if phase <= 3:
			seal_sprite.position = SEAL_POSITIONS[phase]
			seal_sprite.rotation += delta * 2.0
	if seal_label:
		seal_label.visible = (phase <= 3)
		if phase <= 3:
			seal_label.position = SEAL_POSITIONS[phase] + Vector2(-65, -48)
			seal_label.text = "SIGILIUL FAZEI " + str(phase)
	if portal_entry_sprite:
		portal_entry_sprite.visible = (phase == 3)
	if portal_exit_sprite:
		portal_exit_sprite.visible = (phase == 3)

func _process_boss_phase(delta: float, player: Node2D) -> void:
	var local_p: Vector2 = player.global_position - global_position

	if phase >= 2 and abs(local_p.x) > 95.0 and abs(local_p.x) < 260.0 and local_p.y > -260.0:
		if player.has_method("apply_wind"):
			player.apply_wind(Vector2(0, -640.0))

	if phase == 3 and local_p.distance_to(PORTAL_ENTRY_POS) < 38.0:
		player.global_position = global_position + PORTAL_EXIT_POS
		if "velocity" in player:
			player.velocity = Vector2(0, -180)

	var seal_pos: Vector2 = SEAL_POSITIONS.get(phase, Vector2.ZERO)
	if local_p.distance_to(seal_pos) < 44.0:
		_advance_phase(player)
		return

	attack_timer -= delta
	if attack_timer <= 1.0 and not is_telegraphing:
		is_telegraphing = true

	if attack_timer <= 0.0:
		attack_timer = 3.2 - float(phase) * 0.35
		is_telegraphing = false
		var dir: Vector2 = (local_p + Vector2(0, -28) - guardian_pos).normalized()
		var osp := Sprite2D.new()
		osp.texture = proj_tex
		osp.position = guardian_pos + Vector2(0, 20)
		add_child(osp)
		orbs.append({
			"pos": guardian_pos + Vector2(0, 20),
			"vel": dir * (175.0 + phase * 20.0),
			"age": 0.0,
			"life": 2.6,
			"sprite": osp
		})

	var i := orbs.size() - 1
	while i >= 0:
		var o = orbs[i]
		o["age"] += delta
		o["pos"] += o["vel"] * delta
		var osp: Sprite2D = o["sprite"]
		if is_instance_valid(osp):
			osp.position = o["pos"]
		if (o["pos"] as Vector2).distance_to(local_p + Vector2(0, -28)) < 20.0:
			if has_node("/root/GameManager"):
				GameManager.take_damage(1)
			if player.has_method("apply_knockback"):
				player.apply_knockback(Vector2(sign(o["vel"].x), -0.6), 350.0)
			if is_instance_valid(osp):
				osp.queue_free()
			orbs.remove_at(i)
		elif o["age"] >= o["life"]:
			if is_instance_valid(osp):
				osp.queue_free()
			orbs.remove_at(i)
		i -= 1

func _advance_phase(player: Node2D) -> void:
	for o in orbs:
		var osp: Sprite2D = o["sprite"]
		if is_instance_valid(osp):
			osp.queue_free()
	orbs.clear()
	is_telegraphing = false
	attack_timer = 2.6

	if player.has_method("bounce"):
		player.bounce(620.0, 0.0, true)

	if phase < 3:
		phase += 1
		var msg := "FAZA 2: Folosește curenții de aer și Pana Vântului!" if phase == 2 else "FAZA 3: Folosește portalul runic din stânga!"
		if has_node("/root/GameManager"):
			GameManager.add_score(400)
			GameManager.show_banner("PROVOCAREA GUARDIANULUI – FAZA " + str(phase) + " / 3", msg, Color(1.0, 0.88, 0.35))
	else:
		phase = 4
		_trigger_victory_and_gate_opening(player)

func _trigger_victory_and_gate_opening(_player: Node2D) -> void:
	if is_cinematic_playing:
		return
	is_cinematic_playing = true
	if has_node("/root/GameManager"):
		GameManager.add_score(1000)

	var lines = [
		{
			"speaker": "Guardianul Sanctuarului",
			"avatar": "guardian",
			"text": "Nu ai fost cel mai puternic. Dar ai continuat să mergi înainte."
		},
		{
			"speaker": "Eu",
			"avatar": GameManager.current_character,
			"text": "Chiar și când am căzut, am găsit puterea să mă ridic. Casa mea este chiar dincolo de această poartă!"
		}
	]
	if has_node("/root/DialogueManager"):
		DialogueManager.start_dialogue(lines)
		await DialogueManager.dialogue_ended

	if has_node("/root/GameManager"):
		GameManager.show_banner("POARTA SANCTUARULUI SE DESCHIDE!", "Cele patru relicve luminează drumul spre casă!", Color(1.0, 0.92, 0.4))
	var hud = get_tree().current_scene.get_node_or_null("HUD") if get_tree() and get_tree().current_scene else null
	if hud and hud.has_method("flash_screen"):
		hud.flash_screen(Color(1.0, 0.9, 0.45, 0.9), 1.4)

	var tw = create_tween()
	tw.tween_property(self, "gate_open_progress", 1.0, 1.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished

	if target_gate:
		var g = get_node_or_null(target_gate)
		if g and g.has_method("unlock"):
			g.unlock()
