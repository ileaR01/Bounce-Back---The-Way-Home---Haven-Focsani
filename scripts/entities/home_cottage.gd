extends Area2D

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
var is_reached: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if is_reached:
		return
	if body.is_in_group("player"):
		is_reached = true
		_celebrate_arrival(body)

func _celebrate_arrival(player: Node2D) -> void:
	if "velocity" in player:
		player.velocity = Vector2.ZERO

	var lines = [
		{
			"speaker": "Eu",
			"avatar": GameManager.current_character,
			"text": "Am crezut că nu voi mai ajunge niciodată acasă..."
		},
		{
			"speaker": "Licuriciul Magic",
			"avatar": "firefly",
			"text": "Dar ai continuat să încerci."
		},
		{
			"speaker": "Eu",
			"avatar": GameManager.current_character,
			"text": "Am căzut, m-am pierdut, am greșit... dar m-am ridicat de fiecare dată."
		},
		{
			"speaker": "Licuriciul Magic",
			"avatar": "firefly",
			"text": "Asta înseamnă să faci Bounce Back!"
		}
	]

	if has_node("/root/DialogueManager"):
		DialogueManager.start_dialogue(lines)
		await DialogueManager.dialogue_ended

	if has_node("/root/GameManager"):
		GameManager.complete_level()
	await get_tree().create_timer(0.8).timeout
	if has_node("/root/LevelManager"):
		LevelManager.go_to_victory()
