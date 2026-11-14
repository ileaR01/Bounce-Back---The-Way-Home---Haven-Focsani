extends Node2D
class_name RuneSequencePuzzle

@export var correct_sequence: Array[int] = [1, 2, 3, 4]
@export var target_gate: NodePath
@export var secret_wall_gate: NodePath

var current_step: int = 0
var pillars: Array[RunePillar] = []
var is_solved: bool = false

func _ready() -> void:
	for child in get_children():
		if child is RunePillar:
			pillars.append(child)
			child.pillar_activated.connect(_on_pillar_activated)

func _on_pillar_activated(pillar_id: int) -> void:
	if is_solved:
		return
	if current_step < correct_sequence.size() and pillar_id == correct_sequence[current_step]:
		current_step += 1
		if current_step >= correct_sequence.size():
			_solve_puzzle()
	else:
		_fail_sequence()

func _solve_puzzle() -> void:
	is_solved = true

	if has_node("/root/GameManager"):
		GameManager.add_score(400)
		GameManager.show_banner("ORDINEA RUNICĂ CORECTĂ!", "Un perete secret și poarta labirintului s-au deschis!", Color(0.4, 1.0, 0.65))

	var tree = get_tree()
	var player = tree.get_first_node_in_group("player") if tree else null

	if target_gate:
		var gate = get_node_or_null(target_gate)
		if gate and gate.has_method("unlock"):
			gate.unlock()
	if secret_wall_gate:
		var sgate = get_node_or_null(secret_wall_gate)
		if sgate and sgate.has_method("unlock"):
			sgate.unlock()

func _fail_sequence() -> void:
	current_step = 0

	var tree = get_tree()
	var player = tree.get_first_node_in_group("player") if tree else null
	if player:
		if player.has_method("apply_knockback"):
			player.apply_knockback(Vector2(-1.0, -0.5), 240.0)

	await get_tree().create_timer(0.4).timeout
	for p in pillars:
		p.reset_pillar()
