extends Area2D
class_name PuzzleSwitch

signal switch_toggled(is_active: bool)

@export var is_active: bool = false
@export var target_gate: NodePath
@export var switch_id: String = "switch_1"

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt: Sprite2D = $PromptSprite

var tex_off = preload("res://assets/exported/puzzle_switch_off.svg")
var tex_on = preload("res://assets/exported/puzzle_switch_on.svg")

var player_inside: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt:
		prompt.visible = false
	_update_visuals()

func _unhandled_input(event: InputEvent) -> void:
	if not player_inside or is_active:
		return
	var activate = false
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_E or event.physical_keycode == KEY_E or \
		   event.keycode == KEY_ENTER or event.physical_keycode == KEY_ENTER:
			activate = true
	elif event.is_action_pressed("interact"):
		activate = true

	if activate:
		get_viewport().set_input_as_handled()
		toggle_switch()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true
		if not is_active and prompt:
			prompt.visible = true
		if body.velocity.y > 50.0 and not is_active:
			toggle_switch()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		if prompt:
			prompt.visible = false

func toggle_switch() -> void:
	if is_active:
		return
	is_active = true
	if prompt:
		prompt.visible = false
	_update_visuals()

	var tree = get_tree()
	var player = tree.get_first_node_in_group("player") if tree else null
	if player and player.has_method("trigger_camera_shake"):
		player.trigger_camera_shake(5.0, 0.25)

	switch_toggled.emit(is_active)

	if target_gate:
		var gate = get_node_or_null(target_gate)
		if gate and gate.has_method("unlock"):
			gate.unlock()

func _update_visuals() -> void:
	if sprite:
		sprite.texture = tex_on if is_active else tex_off
		var tw = create_tween()
		tw.tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.1)
		tw.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.2)
