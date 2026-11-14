extends Node

signal health_changed(current_health: int, max_health: int)
signal seeds_changed(level_seeds: int, total_seeds: int)
signal coins_changed(level_coins: int, total_coins: int)
signal stars_changed(level_stars: int, total_stars: int)
signal score_changed(new_score: int)
signal banner_requested(title: String, subtitle: String, color: Color)
signal player_damaged()
signal player_died()
signal player_respawned()
signal player_bounced(strength: float)
signal checkpoint_reached(pos: Vector2)
signal level_completed()

var current_character: String = "boy"
var max_health: int = 3
var current_health: int = 3

var seeds_collected_level: int = 0
var total_seeds_collected: int = 0
var coins_collected_level: int = 0
var total_coins_collected: int = 0
var stars_collected_level: int = 0
var total_stars_collected: int = 0
var score: int = 0
var total_play_time: float = 0.0
var is_in_level: bool = false

var current_level_num: int = 1
var levels_completed_count: int = 0
var active_checkpoint_pos: Vector2 = Vector2.ZERO
var has_checkpoint: bool = false
var is_invulnerable: bool = false

var special_items: Dictionary = {
	"shadow_emblem": false,
	"bounce_crystal": false,
	"rune_heart": false,
	"wind_feather": false
}

const SPECIAL_ITEM_NAMES = {
	"shadow_emblem": "Emblema Umbrelor",
	"bounce_crystal": "Cristalul Bounce",
	"rune_heart": "Inima Runică",
	"wind_feather": "Pana Vântului"
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if has_node("/root/SaveManager"):
		current_character = SaveManager.selected_character
		total_seeds_collected = SaveManager.total_seeds
		total_coins_collected = SaveManager.total_coins
		total_stars_collected = SaveManager.total_stars
		for k in SaveManager.special_items:
			special_items[k] = SaveManager.special_items[k]

func _process(delta: float) -> void:
	if is_in_level and not get_tree().paused:
		total_play_time += delta

func set_character(char_name: String) -> void:
	current_character = char_name
	if has_node("/root/SaveManager"):
		SaveManager.selected_character = char_name
		SaveManager.save_data()

func reset_game_state() -> void:
	current_level_num = 1
	current_health = max_health
	seeds_collected_level = 0
	total_seeds_collected = 0
	coins_collected_level = 0
	total_coins_collected = 0
	stars_collected_level = 0
	total_stars_collected = 0
	score = 0
	total_play_time = 0.0
	levels_completed_count = 0
	has_checkpoint = false
	active_checkpoint_pos = Vector2.ZERO
	is_invulnerable = false
	special_items = {
		"shadow_emblem": false,
		"bounce_crystal": false,
		"rune_heart": false,
		"wind_feather": false
	}

func start_level(level_num: int) -> void:
	current_level_num = level_num
	current_health = max_health
	seeds_collected_level = 0
	coins_collected_level = 0
	stars_collected_level = 0
	has_checkpoint = false
	active_checkpoint_pos = Vector2.ZERO
	is_invulnerable = false
	is_in_level = true

	if level_num >= 2:
		special_items["shadow_emblem"] = true
	if level_num >= 3:
		special_items["bounce_crystal"] = true
	if level_num >= 4:
		special_items["rune_heart"] = true
	if level_num >= 5:
		special_items["wind_feather"] = true

	health_changed.emit(current_health, max_health)
	seeds_changed.emit(seeds_collected_level, total_seeds_collected)
	coins_changed.emit(coins_collected_level, total_coins_collected)
	stars_changed.emit(stars_collected_level, total_stars_collected)
	score_changed.emit(score)

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)
	if has_node("/root/SaveManager") and score > SaveManager.high_score:
		SaveManager.high_score = score

func take_damage(amount: int = 1, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if is_invulnerable or current_health <= 0:
		return

	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	player_damaged.emit()

	if current_health <= 0:
		handle_death()
	else:
		_trigger_invulnerability(1.2)

func _trigger_invulnerability(duration: float) -> void:
	is_invulnerable = true
	var tree = get_tree()
	if tree:
		await tree.create_timer(duration).timeout
	is_invulnerable = false

func handle_death() -> void:
	player_died.emit()

	var tree = get_tree()
	if tree:
		await tree.create_timer(1.1).timeout

	respawn_player()

func respawn_player() -> void:
	current_health = max_health
	is_invulnerable = false
	health_changed.emit(current_health, max_health)
	player_respawned.emit()
	_trigger_invulnerability(1.2)

func collect_seed() -> void:
	collect_coin(1)

func collect_coin(amount: int = 1) -> void:
	seeds_collected_level += amount
	total_seeds_collected += amount
	coins_collected_level += amount
	total_coins_collected += amount
	add_score(50 * amount)
	seeds_changed.emit(seeds_collected_level, total_seeds_collected)
	coins_changed.emit(coins_collected_level, total_coins_collected)
	if has_node("/root/SaveManager"):
		SaveManager.total_seeds = total_seeds_collected
		SaveManager.total_coins = total_coins_collected
		SaveManager.save_data()

func collect_star() -> void:
	stars_collected_level += 1
	total_stars_collected += 1
	add_score(250)
	stars_changed.emit(stars_collected_level, total_stars_collected)
	if has_node("/root/SaveManager"):
		SaveManager.total_stars = total_stars_collected
		SaveManager.save_data()

func unlock_special_item(item_key: String) -> void:
	var already_had = bool(special_items.get(item_key, false))
	special_items[item_key] = true
	var item_name = SPECIAL_ITEM_NAMES.get(item_key, item_key)
	if not already_had:
		add_score(500)
	if has_node("/root/SaveManager"):
		SaveManager.set_special_item(item_key, true)

	show_banner("OBIECT SPECIAL OBȚINUT: " + item_name.to_upper() + "!", "Salvat în progresul călătoriei tale spre casă.", Color(1.0, 0.88, 0.35))

func has_special_item(item_key: String) -> bool:
	return bool(special_items.get(item_key, false))

func show_banner(title: String, subtitle: String = "", color: Color = Color(0.85, 0.65, 1.0)) -> void:
	banner_requested.emit(title, subtitle, color)

func set_checkpoint(pos: Vector2) -> void:
	if not has_checkpoint or active_checkpoint_pos.distance_to(pos) > 10.0:
		has_checkpoint = true
		active_checkpoint_pos = pos
		add_score(100)
		checkpoint_reached.emit(pos)
		show_banner("CHECKPOINT", "", Color(0.35, 0.95, 0.55))

func trigger_bounce(strength: float) -> void:
	player_bounced.emit(strength)

func complete_level() -> void:
	add_score(1000)
	levels_completed_count = max(levels_completed_count, current_level_num)
	if has_node("/root/SaveManager"):
		SaveManager.unlock_level(min(5, current_level_num + 1))
	level_completed.emit()

func get_formatted_time() -> String:
	var total_sec: int = int(total_play_time)
	var mins: int = total_sec / 60
	var secs: int = total_sec % 60
	return "%02d:%02d" % [mins, secs]
