extends LevelBase

func _build_level() -> void:
	level_number = 5
	level_width = 9900.0
	fall_death_y = 1080.0
	camera_top_limit = -800
	if spawn_point:
		spawn_point.position = Vector2(120, 520)

	add_ground_run(100, 580, 6)
	add_decor(Vector2(200, 532), "ruin_arch")

	add_npc(
		Vector2(360, 532),
		"Guardianul Sanctuarului",
		"guardian",
		"guardian",
		[
			"GUARDIANUL: Ai ajuns până aici. Dar ești pregătit să treci mai departe?",
			"JUCĂTORUL: Am învățat să nu renunț. Voi încerca!"
		],
		[
			"GUARDIANUL: Dovedește că stăpânești portalurile, săritura bounce, runele și vântul!"
		],
		true,
		false
	)
	add_coin_row(Vector2(540, 490), 5, 65.0, 20.0)

	add_ground_run(1140, 560, 3)
	add_decor(Vector2(1320, 512), "cracked_wall_hint")

	add_platform(Vector2(1380, 700), 260.0)
	var portal_m := SecretPortal.new()
	portal_m.position = Vector2(1420, 652)
	portal_m.target_position = Vector2(1960, 320)
	portal_m.banner_title = "SIGILIUL PORTALULUI ACTIVAT!"
	portal_m.banner_subtitle = "Ai folosit înțelepciunea din Sanctuarul Umbrelor."
	add_child(portal_m)

	add_platform(Vector2(1660, 440), 140.0)
	add_platform(Vector2(1960, 380), 240.0)
	add_coin_row(Vector2(1880, 310), 4, 55.0, 0.0)

	add_platform(Vector2(2300, 520), 180.0)
	add_mushroom(Vector2(2340, 472), "small", 660.0)
	add_platform(Vector2(2540, 380), 160.0)
	add_mushroom(Vector2(2560, 332), "medium", 860.0)
	add_platform(Vector2(2780, 220), 180.0)
	add_mushroom(Vector2(2800, 172), "large", 1040.0)
	add_platform(Vector2(3020, 120), 180.0)
	add_star(Vector2(3020, 50), "l5_star_bounce")
	add_coin_row(Vector2(2520, 240), 4, 75.0, 35.0)

	add_platform(Vector2(3240, 500), 220.0)
	add_checkpoint(Vector2(3240, 452))

	add_ground_run(3500, 500, 6)
	add_star(Vector2(4260, 340), "l5_star_runes")

	add_wind(Vector2(4680, 400), Vector2(200, -640), 260.0, 360.0)
	add_platform(Vector2(4940, 320), 160.0)
	add_wind(Vector2(5180, 360), Vector2(220, -640), 260.0, 360.0)
	add_coin_row(Vector2(4720, 240), 5, 110.0, 30.0)

	add_platform(Vector2(5520, 500), 240.0)
	add_checkpoint(Vector2(5520, 452))

	add_platform(Vector2(5780, 500), 180.0)
	add_mushroom(Vector2(5820, 452), "medium", 880.0)
	add_moving_platform(Vector2(6040, 360), Vector2(160, 0), 2.3)
	add_blade(Vector2(6120, 290), Vector2(0, 90), 1.9)

	add_wind(Vector2(6380, 380), Vector2(180, -620), 220.0, 320.0)
	add_platform(Vector2(6620, 320), 200.0)
	add_retractable_spikes(Vector2(6620, 272), 2.6, 0.0)
	add_star(Vector2(6620, 180), "l5_star_combined")

	add_Ground_Or_Bridge_To_Boss()

func add_Ground_Or_Bridge_To_Boss() -> void:
	var tdoor := TimedDoorPuzzle.new()
	tdoor.position = Vector2(6840, 452)
	tdoor.door_offset = Vector2(240, 0)
	tdoor.open_duration = 9.0
	add_child(tdoor)

	add_ground_run(6860, 500, 4)
	add_enemy_guardian(Vector2(6980, 440), 65.0)
	add_checkpoint(Vector2(7260, 452))

	add_ground_run(7440, 500, 6)

	add_flower(Vector2(7460, 452), 700.0)
	add_platform(Vector2(7590, 370), 150.0)
	add_flower(Vector2(8020, 452), 760.0)
	add_platform(Vector2(7945, 300), 150.0)
	add_platform(Vector2(7760, 260), 150.0)

	add_ground_run(8240, 500, 3)
	var final_gate = add_gate(Vector2(8220, 410), "SanctuaryGrandGate")

	var boss := SanctuaryBossEncounter.new()
	boss.position = Vector2(7760, 500)
	add_child(boss)
	boss.target_gate = boss.get_path_to(final_gate)

	add_switch(Vector2(8120, 452), final_gate)

	add_ground_run(8680, 500, 7, 160.0, "meadow")
	add_decor(Vector2(8740, 444), "meadow_tree")
	add_decor(Vector2(8860, 444), "glow_flora", "", "", Color(1.0, 0.85, 0.35))
	add_decor(Vector2(9020, 444), "meadow_tree")
	add_decor(Vector2(9160, 444), "glow_flora", "", "", Color(0.95, 0.55, 0.85))
	add_decor(Vector2(9300, 444), "meadow_tree")
	add_coin_row(Vector2(8800, 420), 6, 75.0, 15.0)

	add_cottage(Vector2(9480, 444))
