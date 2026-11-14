extends Node

const SAVE_PATH: String = "user://bounce_back_save.json"

var selected_character: String = "boy"
var unlocked_level: int = 1
var total_seeds: int = 0
var total_coins: int = 0
var total_stars: int = 0
var high_score: int = 0
var special_items: Dictionary = {
	"shadow_emblem": false,
	"bounce_crystal": false,
	"rune_heart": false,
	"wind_feather": false
}
var music_volume: float = 0.8
var sfx_volume: float = 0.9
var is_fullscreen: bool = false

func _ready() -> void:
	load_data()

func save_data() -> void:
	var data: Dictionary = {
		"selected_character": selected_character,
		"unlocked_level": unlocked_level,
		"total_seeds": total_seeds,
		"total_coins": total_coins,
		"total_stars": total_stars,
		"high_score": high_score,
		"special_items": special_items,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"is_fullscreen": is_fullscreen
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data, "\t")
		file.store_string(json_string)
		file.close()

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var content = file.get_as_text()
	file.close()
	var json = JSON.new()
	var parse_result = json.parse(content)
	if parse_result == OK and json.data is Dictionary:
		var d: Dictionary = json.data
		selected_character = str(d.get("selected_character", "boy"))
		unlocked_level = clampi(int(d.get("unlocked_level", 1)), 1, 5)
		total_seeds = int(d.get("total_seeds", 0))
		total_coins = int(d.get("total_coins", total_seeds))
		total_stars = int(d.get("total_stars", 0))
		high_score = int(d.get("high_score", 0))
		if d.has("special_items") and d["special_items"] is Dictionary:
			for k in d["special_items"]:
				special_items[k] = bool(d["special_items"][k])
		music_volume = float(d.get("music_volume", 0.8))
		sfx_volume = float(d.get("sfx_volume", 0.9))
		is_fullscreen = bool(d.get("is_fullscreen", false))

func unlock_level(lvl: int) -> void:
	if lvl > unlocked_level:
		unlocked_level = clampi(lvl, 1, 5)
		save_data()

func set_special_item(item_key: String, owned: bool = true) -> void:
	special_items[item_key] = owned
	save_data()

func has_special_item(item_key: String) -> bool:
	return bool(special_items.get(item_key, false))

func reset_progress() -> void:
	unlocked_level = 1
	total_seeds = 0
	total_coins = 0
	total_stars = 0
	high_score = 0
	special_items = {
		"shadow_emblem": false,
		"bounce_crystal": false,
		"rune_heart": false,
		"wind_feather": false
	}
	save_data()
