extends CanvasLayer

@onready var top_bar: Panel = $TopBar
@onready var heart1: TextureRect = $TopBar/HeartsContainer/Heart1
@onready var heart2: TextureRect = $TopBar/HeartsContainer/Heart2
@onready var heart3: TextureRect = $TopBar/HeartsContainer/Heart3
@onready var seeds_label: Label = $TopBar/SeedsContainer/SeedsLabel
@onready var level_label: Label = $TopBar/LevelLabel
@onready var pause_btn: Button = $TopBar/PauseButton
@onready var pause_menu: Control = $PauseMenu

var tex_heart_full = preload("res://assets/exported/heartFull.svg")
var tex_heart_empty = preload("res://assets/exported/heartEmpty.svg")

var score_label: Label
var stars_label: Label
var relics_label: Label
var banner_panel: PanelContainer
var banner_title: Label
var banner_subtitle: Label
var screen_flash: ColorRect
var banner_tween: Tween

const LEVEL_NAMES = {
	1: "Nivelul 1 – Sanctuarul Umbrelor",
	2: "Nivelul 2 – Pădurea de Abis",
	3: "Nivelul 3 – Labirintul Runic",
	4: "Nivelul 4 – Canionul Vânturilor",
	5: "Nivelul 5 – Poarta Sanctuarului"
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.visible = false

	_build_extended_hud()

	GameManager.health_changed.connect(_on_health_changed)
	GameManager.seeds_changed.connect(_on_seeds_changed)
	GameManager.coins_changed.connect(_on_coins_changed)
	GameManager.stars_changed.connect(_on_stars_changed)
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.banner_requested.connect(show_banner)
	pause_btn.pressed.connect(_on_pause_pressed)

	$PauseMenu/Panel/VBoxContainer/ResumeBtn.pressed.connect(_on_resume_pressed)
	$PauseMenu/Panel/VBoxContainer/RestartBtn.pressed.connect(_on_restart_pressed)
	$PauseMenu/Panel/VBoxContainer/MenuBtn.pressed.connect(_on_menu_pressed)

	_on_health_changed(GameManager.current_health, GameManager.max_health)
	_on_coins_changed(GameManager.coins_collected_level, GameManager.total_coins_collected)
	_on_stars_changed(GameManager.stars_collected_level, GameManager.total_stars_collected)
	_on_score_changed(GameManager.score)

	var lvl_num = GameManager.current_level_num
	level_label.text = LEVEL_NAMES.get(lvl_num, "Sanctuarul Magic")

func _build_extended_hud() -> void:
	screen_flash = ColorRect.new()
	screen_flash.name = "ScreenFlash"
	screen_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen_flash.color = Color(0.5, 0.1, 0.8, 0.0)
	add_child(screen_flash)
	move_child(screen_flash, 0)

	var stats_box := HBoxContainer.new()
	stats_box.position = Vector2(280, 12)
	stats_box.size = Vector2(310, 36)
	stats_box.add_theme_constant_override("separation", 16)
	top_bar.add_child(stats_box)

	stars_label = Label.new()
	stars_label.add_theme_font_size_override("font_size", 18)
	stars_label.add_theme_color_override("font_color", Color(0.55, 0.92, 1.0))
	stars_label.text = "★ 0"
	stats_box.add_child(stars_label)

	score_label = Label.new()
	score_label.add_theme_font_size_override("font_size", 18)
	score_label.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
	score_label.text = "Scor: 0"
	stats_box.add_child(score_label)

	relics_label = Label.new()
	relics_label.position = Vector2(880, 14)
	relics_label.size = Vector2(220, 32)
	relics_label.add_theme_font_size_override("font_size", 15)
	relics_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	top_bar.add_child(relics_label)

	level_label.offset_left = -140
	level_label.offset_right = 200
	level_label.add_theme_font_size_override("font_size", 18)

	banner_panel = PanelContainer.new()
	banner_panel.anchor_left = 0.5
	banner_panel.anchor_right = 0.5
	banner_panel.offset_left = -340
	banner_panel.offset_right = 340
	banner_panel.offset_top = 110
	banner_panel.offset_bottom = 190
	banner_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner_panel.modulate.a = 0.0
	var bstyle := StyleBoxFlat.new()
	bstyle.bg_color = Color(0.12, 0.08, 0.22, 0.92)
	bstyle.border_width_left = 2
	bstyle.border_width_top = 2
	bstyle.border_width_right = 2
	bstyle.border_width_bottom = 2
	bstyle.border_color = Color(0.85, 0.55, 1.0, 0.95)
	bstyle.corner_radius_top_left = 14
	bstyle.corner_radius_top_right = 14
	bstyle.corner_radius_bottom_left = 14
	bstyle.corner_radius_bottom_right = 14
	bstyle.content_margin_left = 20
	bstyle.content_margin_right = 20
	bstyle.content_margin_top = 10
	bstyle.content_margin_bottom = 10
	banner_panel.add_theme_stylebox_override("panel", bstyle)
	add_child(banner_panel)

	var b_vbox := VBoxContainer.new()
	b_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	banner_panel.add_child(b_vbox)

	banner_title = Label.new()
	banner_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_title.add_theme_font_size_override("font_size", 20)
	banner_title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	b_vbox.add_child(banner_title)

	banner_subtitle = Label.new()
	banner_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_subtitle.add_theme_font_size_override("font_size", 15)
	banner_subtitle.add_theme_color_override("font_color", Color(0.92, 0.92, 0.98))
	b_vbox.add_child(banner_subtitle)

func flash_screen(col: Color, duration: float = 0.65) -> void:
	if not screen_flash:
		return
	screen_flash.color = col
	screen_flash.color.a = 0.85
	var tw = create_tween()
	tw.tween_property(screen_flash, "color:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func show_banner(title: String, subtitle: String = "", col: Color = Color(1.0, 0.88, 0.35)) -> void:
	if not banner_panel:
		return
	banner_title.text = title
	banner_title.add_theme_color_override("font_color", col)
	banner_subtitle.text = subtitle
	banner_subtitle.visible = (subtitle != "")

	if banner_tween and banner_tween.is_valid():
		banner_tween.kill()
	banner_panel.modulate.a = 0.0
	banner_panel.offset_top = 95
	banner_tween = create_tween()
	banner_tween.tween_property(banner_panel, "modulate:a", 1.0, 0.22)
	banner_tween.parallel().tween_property(banner_panel, "offset_top", 110.0, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	banner_tween.tween_interval(3.0)
	banner_tween.tween_property(banner_panel, "modulate:a", 0.0, 0.35)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		get_viewport().set_input_as_handled()
		toggle_pause()

func toggle_pause() -> void:
	if get_tree().paused:
		_on_resume_pressed()
	else:
		_on_pause_pressed()

func _on_pause_pressed() -> void:
	get_tree().paused = true
	pause_menu.visible = true
	pause_menu.modulate.a = 0.0
	var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(pause_menu, "modulate:a", 1.0, 0.15)

func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_menu.visible = false

func _on_restart_pressed() -> void:
	get_tree().paused = false
	LevelManager.restart_level()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	LevelManager.go_to_main_menu()

func _on_health_changed(current: int, _max_h: int) -> void:
	heart1.texture = tex_heart_full if current >= 1 else tex_heart_empty
	heart2.texture = tex_heart_full if current >= 2 else tex_heart_empty
	heart3.texture = tex_heart_full if current >= 3 else tex_heart_empty

func _on_seeds_changed(lvl_seeds: int, _total_seeds: int) -> void:
	seeds_label.text = str(lvl_seeds)

func _on_coins_changed(lvl_coins: int, _total_coins: int) -> void:
	seeds_label.text = str(lvl_coins)

func _on_stars_changed(lvl_stars: int, total_stars: int) -> void:
	if stars_label:
		stars_label.text = "★ " + str(lvl_stars) + " (" + str(total_stars) + ")"

func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = "Scor: " + str(new_score)
