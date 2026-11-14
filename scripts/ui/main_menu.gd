extends Control

@onready var title_label: Label = $VBoxTitle/TitleLabel
@onready var play_btn: Button = $MenuButtons/PlayBtn
@onready var char_btn: Button = $MenuButtons/CharBtn
@onready var exit_btn: Button = $MenuButtons/ExitBtn

@onready var preview_char: TextureRect = $CharPreview/TextureRect
@onready var preview_label: Label = $CharPreview/Label

func _ready() -> void:
	title_label.text = "BOUNCE BACK – THE WAY HOME"

	play_btn.pressed.connect(_on_play_pressed)
	char_btn.pressed.connect(_on_char_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)

	_update_char_preview()

func _update_char_preview() -> void:
	var char_name = GameManager.current_character
	var path = "res://assets/player/" + char_name + "/default.svg"
	if ResourceLoader.exists(path):
		preview_char.texture = load(path)
	preview_label.text = "Caracterul tau"

func _process(_delta: float) -> void:
	var t = Time.get_ticks_msec() / 1000.0
	title_label.position.y = sin(t * 2.0) * 4.0
	preview_char.scale = Vector2(1.0 + sin(t * 3.0) * 0.04, 1.0 - sin(t * 3.0) * 0.04)

func _on_play_pressed() -> void:
	if has_node("/root/GameManager"):
		GameManager.reset_game_state()
	LevelManager.load_level(1)

func _on_char_pressed() -> void:
	LevelManager.go_to_character_select()

func _on_exit_pressed() -> void:
	get_tree().quit()
