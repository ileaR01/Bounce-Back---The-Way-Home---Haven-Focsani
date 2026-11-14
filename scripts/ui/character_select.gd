extends Control

@onready var boy_panel: Panel = $CardsContainer/BoyPanel
@onready var girl_panel: Panel = $CardsContainer/GirlPanel
@onready var boy_tex_rect: TextureRect = $CardsContainer/BoyPanel/TextureRect
@onready var girl_tex_rect: TextureRect = $CardsContainer/GirlPanel/TextureRect
@onready var boy_select_btn: Button = $CardsContainer/BoyPanel/SelectBtn
@onready var girl_select_btn: Button = $CardsContainer/GirlPanel/SelectBtn
@onready var back_btn: Button = $BackBtn
@onready var confirm_btn: Button = $ConfirmBtn

var current_choice: String = "boy"

var boy_style_selected: StyleBoxFlat
var boy_style_unselected: StyleBoxFlat
var girl_style_selected: StyleBoxFlat
var girl_style_unselected: StyleBoxFlat

func _ready() -> void:
	current_choice = GameManager.current_character

	boy_select_btn.pressed.connect(func(): _choose("boy"))
	girl_select_btn.pressed.connect(func(): _choose("girl"))
	back_btn.pressed.connect(_on_back_pressed)
	confirm_btn.pressed.connect(_on_confirm_pressed)

	_setup_styles()
	_update_ui()

func _setup_styles() -> void:
	boy_style_selected = StyleBoxFlat.new()
	boy_style_selected.bg_color = Color(0.18, 0.35, 0.55, 0.95)
	boy_style_selected.border_width_left = 4
	boy_style_selected.border_width_top = 4
	boy_style_selected.border_width_right = 4
	boy_style_selected.border_width_bottom = 4
	boy_style_selected.border_color = Color(0.42, 0.78, 1.0, 1.0)
	boy_style_selected.corner_radius_top_left = 20
	boy_style_selected.corner_radius_top_right = 20
	boy_style_selected.corner_radius_bottom_right = 20
	boy_style_selected.corner_radius_bottom_left = 20
	boy_style_selected.shadow_size = 12

	boy_style_unselected = StyleBoxFlat.new()
	boy_style_unselected.bg_color = Color(0.15, 0.2, 0.28, 0.7)
	boy_style_unselected.border_width_left = 2
	boy_style_unselected.border_width_top = 2
	boy_style_unselected.border_width_right = 2
	boy_style_unselected.border_width_bottom = 2
	boy_style_unselected.border_color = Color(0.3, 0.4, 0.5, 0.5)
	boy_style_unselected.corner_radius_top_left = 20
	boy_style_unselected.corner_radius_top_right = 20
	boy_style_unselected.corner_radius_bottom_right = 20
	boy_style_unselected.corner_radius_bottom_left = 20

	girl_style_selected = StyleBoxFlat.new()
	girl_style_selected.bg_color = Color(0.55, 0.22, 0.4, 0.95)
	girl_style_selected.border_width_left = 4
	girl_style_selected.border_width_top = 4
	girl_style_selected.border_width_right = 4
	girl_style_selected.border_width_bottom = 4
	girl_style_selected.border_color = Color(1.0, 0.55, 0.8, 1.0)
	girl_style_selected.corner_radius_top_left = 20
	girl_style_selected.corner_radius_top_right = 20
	girl_style_selected.corner_radius_bottom_right = 20
	girl_style_selected.corner_radius_bottom_left = 20
	girl_style_selected.shadow_size = 12

	girl_style_unselected = StyleBoxFlat.new()
	girl_style_unselected.bg_color = Color(0.28, 0.16, 0.24, 0.7)
	girl_style_unselected.border_width_left = 2
	girl_style_unselected.border_width_top = 2
	girl_style_unselected.border_width_right = 2
	girl_style_unselected.border_width_bottom = 2
	girl_style_unselected.border_color = Color(0.5, 0.3, 0.4, 0.5)
	girl_style_unselected.corner_radius_top_left = 20
	girl_style_unselected.corner_radius_top_right = 20
	girl_style_unselected.corner_radius_bottom_right = 20
	girl_style_unselected.corner_radius_bottom_left = 20

func _choose(char_name: String) -> void:
	current_choice = char_name
	_update_ui()

func _update_ui() -> void:
	if current_choice == "boy":
		boy_panel.add_theme_stylebox_override("panel", boy_style_selected)
		girl_panel.add_theme_stylebox_override("panel", girl_style_unselected)
		boy_select_btn.text = "✓ Selectat"
		girl_select_btn.text = "Alege Fata"
	else:
		boy_panel.add_theme_stylebox_override("panel", boy_style_unselected)
		girl_panel.add_theme_stylebox_override("panel", girl_style_selected)
		boy_select_btn.text = "Alege Băiatul"
		girl_select_btn.text = "✓ Selectată"

func _process(delta: float) -> void:
	var t = Time.get_ticks_msec() / 1000.0
	boy_tex_rect.scale = Vector2(1.0 + sin(t * 3.0) * 0.05, 1.0 - sin(t * 3.0) * 0.05)
	girl_tex_rect.scale = Vector2(1.0 + cos(t * 3.0) * 0.05, 1.0 - cos(t * 3.0) * 0.05)

func _on_confirm_pressed() -> void:
	GameManager.set_character(current_choice)
	LevelManager.go_to_main_menu()

func _on_back_pressed() -> void:
	LevelManager.go_to_main_menu()
