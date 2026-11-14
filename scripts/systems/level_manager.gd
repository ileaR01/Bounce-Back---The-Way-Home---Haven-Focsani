extends Node

const LEVEL_SCENES = [
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_3.tscn",
	"res://scenes/levels/level_4.tscn",
	"res://scenes/levels/level_5.tscn"
]

const MAIN_MENU_SCENE = "res://scenes/menus/main_menu.tscn"
const VICTORY_SCENE = "res://scenes/menus/victory_screen.tscn"
const CHARACTER_SELECT_SCENE = "res://scenes/menus/character_select.tscn"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func load_level(level_num: int) -> void:
	if level_num < 1 or level_num > LEVEL_SCENES.size():
		return
	var scene_path = LEVEL_SCENES[level_num - 1]
	if has_node("/root/GameManager"):
		GameManager.start_level(level_num)
	if has_node("/root/SaveManager"):
		SaveManager.unlock_level(level_num)
	get_tree().change_scene_to_file(scene_path)

func restart_level() -> void:
	var lvl = 1
	if has_node("/root/GameManager"):
		lvl = GameManager.current_level_num
	load_level(lvl)

func next_level() -> void:
	var lvl = 1
	if has_node("/root/GameManager"):
		lvl = GameManager.current_level_num
	if lvl >= 5:
		go_to_victory()
	else:
		if has_node("/root/SaveManager"):
			SaveManager.unlock_level(lvl + 1)
		load_level(lvl + 1)

func go_to_main_menu() -> void:
	if has_node("/root/GameManager"):
		GameManager.is_in_level = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func go_to_victory() -> void:
	if has_node("/root/GameManager"):
		GameManager.is_in_level = false
	get_tree().change_scene_to_file(VICTORY_SCENE)

func go_to_character_select() -> void:
	if has_node("/root/GameManager"):
		GameManager.is_in_level = false
	get_tree().change_scene_to_file(CHARACTER_SELECT_SCENE)
