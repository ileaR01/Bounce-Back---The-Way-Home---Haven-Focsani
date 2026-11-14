extends LevelBase

func _build_level() -> void:
	level_number = 2
	level_width = 9800.0
	fall_death_y = 1080.0
	camera_top_limit = -750
	if spawn_point:
		spawn_point.position = Vector2(120, 520)

	add_ground_run(100, 580, 5)
	add_decor(Vector2(200, 532), "glow_flora", "", "", Color(0.2, 0.95, 0.8))
	add_decor(Vector2(480, 532), "glow_flora", "", "", Color(0.65, 0.4, 1.0))

	add_npc(
		Vector2(340, 532),
		"Iepurașul Prietenos",
		"rabbit",
		"rabbit",
		[
			"IEPURAȘUL: Bine ai venit în Pădurea de Abis! Ai grijă unde calci!",
			"JUCĂTORUL: De ce? Pare destul de liniștită.",
			"IEPURAȘUL: Pentru că unele lucruri te pot ridica mai sus decât ai crede!"
		],
		[
			"IEPURAȘUL: Ciupercile mici, medii și mari au forțe diferite. Folosește-le în ordine!"
		],
		true,
		false
	)

	add_mushroom(Vector2(660, 532), "small", 620.0)
	add_platform(Vector2(860, 420), 180.0)
	add_mushroom(Vector2(900, 372), "medium", 800.0)
	add_platform(Vector2(1100, 260), 180.0)
	add_coin_row(Vector2(820, 350), 4, 48.0, 25.0)

	add_platform(Vector2(1320, 480), 200.0)
	add_platform(Vector2(1540, 520), 200.0)
	add_enemy_caterpillar(Vector2(1540, 460), 70.0, 60.0)
	add_platform(Vector2(1760, 460), 200.0)
	add_mushroom(Vector2(1800, 412), "small", 640.0)
	add_coin_row(Vector2(1480, 430), 4, 50.0, 20.0)

	add_platform(Vector2(1540, 700), 220.0)
	add_platform(Vector2(1780, 700), 200.0)
	add_decor(Vector2(1660, 652), "glow_flora", "", "", Color(0.2, 0.98, 0.85))
	add_star(Vector2(1660, 620), "l2_star_roots")
	add_mushroom(Vector2(1820, 652), "large", 980.0)

	add_platform(Vector2(2040, 520), 220.0)
	add_checkpoint(Vector2(2060, 472))

	add_platform(Vector2(2360, 560), 120.0)
	add_mushroom(Vector2(2360, 512), "small", 640.0)
	add_coin(Vector2(2460, 380))

	add_platform(Vector2(2580, 460), 120.0)
	add_mushroom(Vector2(2580, 412), "medium", 840.0)
	add_coin(Vector2(2700, 260))

	add_platform(Vector2(2820, 360), 130.0)
	add_mushroom(Vector2(2820, 312), "large", 1060.0)
	add_coin_row(Vector2(2920, 120), 3, 50.0, 20.0)

	add_platform(Vector2(3120, 260), 220.0)

	add_platform(Vector2(3360, 480), 160.0)
	add_decor(Vector2(3560, 620), "water_hazard")
	add_decor(Vector2(3760, 620), "water_hazard")
	add_decor(Vector2(3960, 620), "water_hazard")

	add_mushroom(Vector2(3520, 460), "disappearing", 840.0)
	add_crumbling(Vector2(3700, 380), 0.45)
	add_mushroom(Vector2(3880, 440), "moving", 880.0, 0.0, Vector2(120, 0))
	add_mushroom(Vector2(4120, 460), "popup", 960.0)
	add_coin_row(Vector2(3520, 280), 5, 85.0, 35.0)

	add_platform(Vector2(4320, 480), 220.0)
	add_checkpoint(Vector2(4320, 432))

	add_platform(Vector2(4580, 600), 180.0)
	add_enemy_bee(Vector2(4760, 480), 100.0, 75.0)

	add_platform(Vector2(4860, 680), 180.0)
	add_mushroom(Vector2(4900, 632), "medium", 820.0)

	add_platform(Vector2(5140, 820), 260.0)
	add_star(Vector2(5140, 740), "l2_star_cave")
	add_coin_row(Vector2(5060, 750), 4, 50.0, 0.0)
	add_mushroom(Vector2(5220, 772), "large", 1080.0)

	add_platform(Vector2(5420, 580), 160.0)
	add_enemy_bee(Vector2(5420, 420), 90.0, 75.0)
	add_mushroom(Vector2(5440, 532), "large", 1040.0)
	add_platform(Vector2(5660, 440), 200.0)

	add_mushroom(Vector2(5880, 460), "large", 940.0)
	add_mushroom(Vector2(6100, 440), "moving", 920.0, 0.0, Vector2(130, 0))
	add_enemy_bee(Vector2(6180, 290), 110.0, 80.0)
	add_mushroom(Vector2(6380, 440), "disappearing", 940.0)
	add_enemy_bee(Vector2(6480, 280), 110.0, 80.0)
	add_mushroom(Vector2(6600, 440), "large", 980.0)
	add_coin_row(Vector2(5920, 260), 6, 95.0, 30.0)

	add_platform(Vector2(6840, 480), 220.0)
	add_checkpoint(Vector2(6840, 432))

	add_ground_run(7080, 500, 4)
	add_decor(Vector2(7140, 452), "plant_hazard")
	add_enemy_caterpillar(Vector2(7280, 440), 90.0, 85.0)
	add_mushroom(Vector2(7520, 452), "medium", 880.0)
	add_spikes(Vector2(7640, 452))

	add_platform(Vector2(7720, 330), 150.0)
	add_mushroom(Vector2(7720, 282), "medium", 860.0)
	add_platform(Vector2(7540, 160), 160.0)
	add_star(Vector2(7540, 90), "l2_star_dark")
	add_crumbling(Vector2(7880, 340), 0.4)

	add_platform(Vector2(8080, 500), 240.0)
	add_checkpoint(Vector2(8040, 452))

	add_mushroom(Vector2(8160, 452), "giant", 1380.0, 470.0)
	add_coin_row(Vector2(8320, 80), 6, 85.0, 60.0)

	add_platform(Vector2(8460, 560), 160.0)
	add_mushroom(Vector2(8460, 512), "large", 1040.0, 240.0)
	add_platform(Vector2(8740, 500), 180.0)
	add_ground_run(8940, 460, 5)
	add_decor(Vector2(8980, 412), "glow_flora", "", "", Color(0.25, 1.0, 0.8))
	add_decor(Vector2(9200, 412), "glow_flora", "", "", Color(1.0, 0.9, 0.4))

	add_npc(
		Vector2(9120, 412),
		"Iepurașul Prietenos",
		"rabbit",
		"rabbit",
		[
			"IEPURAȘUL: Ai reușit! Chiar dacă ai căzut, ai găsit întotdeauna o cale să te ridici!",
			"JUCĂTORUL: Acum înțeleg! Trebuie să încerc din nou!"
		],
		[],
		true,
		false,
		"bounce_crystal"
	)

	add_relic(Vector2(9280, 350), "bounce_crystal", "CRISTALUL BOUNCE", "Salvat în progresul tău pentru Nivelul 5 – Poarta Sanctuarului!")
	add_exit(Vector2(9480, 412))
