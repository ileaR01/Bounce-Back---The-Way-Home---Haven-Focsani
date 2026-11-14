extends LevelBase

func _build_level() -> void:
	level_number = 3
	level_width = 9600.0
	fall_death_y = 1050.0
	camera_top_limit = -700
	if spawn_point:
		spawn_point.position = Vector2(120, 520)

	add_ground_run(100, 580, 6)
	add_decor(Vector2(200, 532), "torch", "", "", Color(0.45, 0.78, 1.0))

	add_npc(
		Vector2(340, 532),
		"Țestoasa Înțeleaptă",
		"turtle",
		"turtle",
		[
			"ȚESTOASA: Aici viteza nu te va ajuta prea mult.",
			"JUCĂTORUL: Atunci cum trec?",
			"ȚESTOASA: Privește simbolurile. Fiecare dintre ele ascunde o parte din răspuns."
		],
		[
			"ȚESTOASA: Reține ordinea frescelor antice: Lună, Soare, Frunză, Stea."
		],
		true,
		false
	)

	var entry_gate = add_gate(Vector2(880, 480), "EntryRuneGate")
	add_platform(Vector2(700, 420), 140.0)
	add_switch(Vector2(700, 372), entry_gate)
	add_coin_row(Vector2(640, 340), 3, 55.0, 0.0)

	add_ground_run(1140, 560, 7)
	add_coin_row(Vector2(1300, 460), 6, 110.0, 20.0)

	add_flower(Vector2(2100, 512), 700.0)
	add_platform(Vector2(1860, 320), 200.0)
	add_star(Vector2(1860, 250), "l3_star_runes")

	add_ground_run(2340, 540, 3)
	var corr_gate = add_gate(Vector2(3180, 450), "CorridorGate")

	add_moving_platform(Vector2(2780, 500), Vector2(150, -90), 2.5)
	add_platform(Vector2(3040, 340), 160.0)
	add_switch(Vector2(3040, 292), corr_gate)
	add_coin_row(Vector2(2980, 250), 3, 55.0, 0.0)

	add_ground_run(3160, 540, 3)
	add_enemy_snail(Vector2(3280, 480), 65.0, 40.0)
	add_checkpoint(Vector2(3420, 492))

	add_ground_run(3660, 540, 6)
	add_checkpoint(Vector2(4480, 492))

	add_platform(Vector2(4740, 520), 130.0)
	add_crumbling(Vector2(4910, 520), 0.35)
	add_platform(Vector2(5080, 480), 130.0)
	add_crumbling(Vector2(5250, 480), 0.35)
	add_platform(Vector2(5420, 460), 140.0)
	add_star(Vector2(5080, 360), "l3_star_tiles")
	add_coin_row(Vector2(4740, 410), 5, 130.0, 25.0)

	add_ground_run(5740, 520, 8)
	add_flower(Vector2(6680, 472), 760.0)
	add_checkpoint(Vector2(6920, 472))

	add_platform(Vector2(6320, 260), 220.0)
	add_platform(Vector2(6540, 260), 220.0)
	add_star(Vector2(6300, 180), "l3_star_secret")
	add_relic(Vector2(6440, 180), "rune_heart", "INIMA RUNICĂ", "Artefactul înțelepciunii din Camera Secretă a Labirintului!")
	add_coin_row(Vector2(6260, 140), 5, 60.0, 0.0)

	add_ground_run(7120, 520, 4)

	var tdoor := TimedDoorPuzzle.new()
	tdoor.position = Vector2(7180, 472)
	tdoor.door_offset = Vector2(360, 0)
	tdoor.open_duration = 8.0
	add_child(tdoor)

	add_retractable_spikes(Vector2(7340, 472), 2.6, 0.0)
	add_enemy_snail(Vector2(7460, 460), 55.0, 45.0)

	add_moving_platform(Vector2(7760, 480), Vector2(170, -60), 2.4)
	add_blade(Vector2(7960, 390), Vector2(0, 110), 2.0)
	add_platform(Vector2(8160, 440), 200.0)
	add_enemy_guardian(Vector2(8180, 380), 70.0)
	add_coin_row(Vector2(7780, 360), 5, 75.0, 25.0)

	add_platform(Vector2(8460, 460), 220.0)
	add_checkpoint(Vector2(8460, 412))

	add_ground_run(8720, 460, 5)
	add_decor(Vector2(8760, 412), "torch", "", "", Color(1.0, 0.85, 0.35))
	add_decor(Vector2(9180, 412), "torch", "", "", Color(1.0, 0.85, 0.35))

	add_npc(
		Vector2(8880, 412),
		"Țestoasa Înțeleaptă",
		"turtle",
		"turtle",
		[
			"ȚESTOASA: Ai înțeles că nu trebuie să te grăbești mereu. Uneori răspunsul apare atunci când privești cu atenție.",
			"JUCĂTORUL: Mulțumesc! Cu Inima Runică sunt tot mai aproape de casă."
		],
		[],
		true,
		false,
		"rune_heart"
	)

	add_relic(Vector2(9040, 350), "rune_heart", "INIMA RUNICĂ", "Salvată pentru Nivelul 5 – Poarta Sanctuarului!")
	add_exit(Vector2(9240, 412))
