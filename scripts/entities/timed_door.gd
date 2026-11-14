extends Node2D
class_name TimedDoorPuzzle

@export var open_duration: float = 7.5
@export var door_offset: Vector2 = Vector2(260, 0)

var time_left: float = 0.0
var is_open: bool = false
var door_body: StaticBody2D
var door_col: CollisionShape2D
var switch_sprite: Sprite2D
var door_sprite: Sprite2D
var tex_sw_off: Texture2D
var tex_sw_on: Texture2D
var tex_door_closed: Texture2D
var tex_door_open: Texture2D

func _ready() -> void:
	if ResourceLoader.exists("res://assets/elements/timed_switch_off.svg"):
		tex_sw_off = load("res://assets/elements/timed_switch_off.svg")
	if ResourceLoader.exists("res://assets/elements/timed_switch_on.svg"):
		tex_sw_on = load("res://assets/elements/timed_switch_on.svg")
	if ResourceLoader.exists("res://assets/elements/timed_door_closed.svg"):
		tex_door_closed = load("res://assets/elements/timed_door_closed.svg")
	if ResourceLoader.exists("res://assets/elements/timed_door_open.svg"):
		tex_door_open = load("res://assets/elements/timed_door_open.svg")

	switch_sprite = Sprite2D.new()
	switch_sprite.position = Vector2(0, -16)
	switch_sprite.texture = tex_sw_off
	add_child(switch_sprite)

	var sw_area := Area2D.new()
	sw_area.collision_layer = 0
	sw_area.collision_mask = 2
	var scol := CollisionShape2D.new()
	var srect := RectangleShape2D.new()
	srect.size = Vector2(48, 48)
	scol.shape = srect
	scol.position = Vector2(0, -24)
	sw_area.add_child(scol)
	add_child(sw_area)
	sw_area.body_entered.connect(_on_switch_entered)

	door_body = StaticBody2D.new()
	door_body.position = door_offset
	door_body.collision_layer = 1
	door_body.collision_mask = 2
	door_col = CollisionShape2D.new()
	var drect := RectangleShape2D.new()
	drect.size = Vector2(32, 130)
	door_col.shape = drect
	door_col.position = Vector2(0, -65)
	door_body.add_child(door_col)

	door_sprite = Sprite2D.new()
	door_sprite.position = Vector2(0, -65)
	door_sprite.texture = tex_door_closed
	door_body.add_child(door_sprite)
	add_child(door_body)

func _on_switch_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		time_left = open_duration
		if not is_open:
			is_open = true
			door_col.set_deferred("disabled", true)
			if switch_sprite:
				switch_sprite.texture = tex_sw_on
			if door_sprite:
				door_sprite.texture = tex_door_open

func _process(delta: float) -> void:
	if is_open:
		time_left -= delta
		if time_left <= 0.0:
			time_left = 0.0
			is_open = false
			door_col.set_deferred("disabled", false)
			if switch_sprite:
				switch_sprite.texture = tex_sw_off
			if door_sprite:
				door_sprite.texture = tex_door_closed
