extends Control

@onready var cottage_rect: TextureRect = $CottageRect
@onready var hero_rect: TextureRect = $HeroRect
@onready var header_label: Label = $Panel/Header
@onready var stats_vbox: VBoxContainer = $Panel/Stats
@onready var seeds_val_label: Label = $Panel/Stats/SeedsRow/Val
@onready var levels_val_label: Label = $Panel/Stats/LevelsRow/Val
@onready var buttons_hbox: HBoxContainer = $Buttons
@onready var play_again_btn: Button = $Buttons/PlayAgainBtn
@onready var menu_btn: Button = $Buttons/MenuBtn

func _ready() -> void:
	var char_name = GameManager.current_character
	var path = "res://assets/player/" + char_name + "/default.svg"
	if ResourceLoader.exists(path):
		hero_rect.texture = load(path)

	header_label.text = "BOUNCE BACK – THE WAY HOME\nYOU MADE IT HOME!"
	header_label.add_theme_font_size_override("font_size", 22)

	for c in stats_vbox.get_children():
		c.visible = false

	_add_stat_row("Scor Total:", str(GameManager.score) + " puncte", Color(1.0, 0.9, 0.35))
	_add_stat_row("Monede Colectate:", str(GameManager.total_coins_collected), Color(1.0, 0.85, 0.35))
	_add_stat_row("Stele Colectate:", str(GameManager.total_stars_collected), Color(0.45, 0.92, 1.0))
	_add_stat_row("Vieți Rămase:", str(GameManager.current_health) + " / " + str(GameManager.max_health), Color(1.0, 0.45, 0.55))
	_add_stat_row("Timp Total:", GameManager.get_formatted_time(), Color(0.85, 0.95, 1.0))

	play_again_btn.text = "Joacă din nou"
	menu_btn.text = "Main Menu"

	play_again_btn.pressed.connect(_on_play_again_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)

func _add_stat_row(label_text: String, val_text: String, val_col: Color) -> void:
	var row := HBoxContainer.new()
	var l := Label.new()
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.add_theme_font_size_override("font_size", 16)
	l.text = label_text
	var v := Label.new()
	v.add_theme_font_size_override("font_size", 16)
	v.add_theme_color_override("font_color", val_col)
	v.text = val_text
	row.add_child(l)
	row.add_child(v)
	stats_vbox.add_child(row)

func _process(_delta: float) -> void:
	var t = Time.get_ticks_msec() / 1000.0
	hero_rect.scale = Vector2(1.0 + sin(t * 3.0) * 0.05, 1.0 - sin(t * 3.0) * 0.05)

func _on_play_again_pressed() -> void:
	GameManager.reset_game_state()
	LevelManager.load_level(1)

func _on_menu_pressed() -> void:
	LevelManager.go_to_main_menu()
