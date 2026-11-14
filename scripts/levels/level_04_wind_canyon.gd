extends LevelBase

func _build_level() -> void:
	level_number = 4
	level_width = 9800.0
	fall_death_y = 1080.0
	camera_top_limit = -800
	if spawn_point:
		spawn_point.position = Vector2(120, 520)

	add_ground_run(100, 580, 5)
	add_decor(Vector2(200, 532), "signpost", "Ține apăsat SPACE în aer pentru Planare!", "Folosește curenții de vânt în avantajul tău", Color(0.55, 0.9, 1.0))

	add_npc(
		Vector2(360, 532),
		"Pasărea Vântului",
		"wind_bird",
		"wind_bird",
		[
			"PASĂREA: Nu încerca să lupți împotriva vântului!",
			"JUCĂTORUL: Dar mă împinge înapoi!",
			"PASĂREA: Atunci învață să îl folosești."
		],
		[
			"PASĂREA: Urmărește particulele din aer — ele îți arată mereu direcția rafalei!"
		],
		true,
		false
	)

	add_wind(Vector2(820, 460), Vector2(140, -580), 220.0, 280.0)
	add_platform(Vector2(1040, 380), 200.0)
	add_coin_row(Vector2(780, 360), 4, 55.0, 30.0)

	add_platform(Vector2(1280, 460), 180.0)
	add_alt_wind(Vector2(1500, 400), Vector2(210, -540), Vector2(-110, -480), 3.4, 260.0, 320.0)
	add_platform(Vector2(1740, 380), 180.0)
	add_alt_wind(Vector2(1960, 380), Vector2(220, -540), Vector2(-100, -480), 3.4, 260.0, 320.0)
	add_coin_row(Vector2(1440, 260), 5, 95.0, 25.0)

	add_platform(Vector2(2200, 480), 220.0)
	add_checkpoint(Vector2(2200, 432))

	add_moving_platform(Vector2(2460, 460), Vector2(0, -140), 2.4)
	add_moving_platform(Vector2(2680, 340), Vector2(180, 0), 2.5)
	add_platform(Vector2(2980, 260), 160.0)
	add_star(Vector2(2980, 190), "l4_star_floating")
	add_moving_platform(Vector2(3180, 380), Vector2(150, 80), 2.6)
	add_coin_row(Vector2(2620, 250), 4, 65.0, 20.0)

	add_platform(Vector2(3520, 500), 180.0)
	add_wind(Vector2(3720, 340), Vector2(80, -680), 220.0, 440.0)
	add_platform(Vector2(3920, 180), 180.0)
	add_star(Vector2(3920, 110), "l4_star_tunnel")
	add_wind(Vector2(4140, 240), Vector2(260, -440), 280.0, 260.0)
	add_coin_row(Vector2(3700, 180), 5, 85.0, 30.0)

	add_platform(Vector2(4480, 480), 240.0)
	add_checkpoint(Vector2(4480, 432))

	add_platform(Vector2(4760, 480), 130.0)
	add_crumbling(Vector2(4940, 480), 0.42)
	add_wind(Vector2(5120, 460), Vector2(180, -560), 180.0, 260.0)
	add_platform(Vector2(5320, 440), 130.0)
	add_crumbling(Vector2(5500, 440), 0.42)
	add_platform(Vector2(5680, 460), 180.0)
	add_coin_row(Vector2(4840, 380), 5, 110.0, 25.0)

	add_ground_run(5880, 500, 3)
	add_falling_rock(Vector2(5960, 180), 320.0, 3.2, 0.0)
	add_enemy_bee(Vector2(6140, 360), 95.0, 80.0)
	add_crumbling(Vector2(6340, 480), 0.4)
	add_falling_rock(Vector2(6500, 180), 320.0, 3.2, 1.4)
	add_platform(Vector2(6540, 480), 160.0)
	add_enemy_bee(Vector2(6640, 340), 90.0, 80.0)

	add_platform(Vector2(6820, 480), 220.0)
	add_checkpoint(Vector2(6820, 432))

	add_ground_run(7080, 500, 3)
	add_lightning(Vector2(7160, 452), 3.8, 0.0, 360.0)
	add_alt_wind(Vector2(7360, 380), Vector2(220, -560), Vector2(-120, -500), 3.2, 260.0, 320.0)
	add_crumbling(Vector2(7540, 440), 0.42)
	add_falling_rock(Vector2(7680, 140), 340.0, 3.4, 0.8)
	add_platform(Vector2(7740, 440), 180.0)
	add_lightning(Vector2(7780, 392), 3.8, 1.9, 360.0)
	add_star(Vector2(7540, 280), "l4_star_storm")
	add_coin_row(Vector2(7140, 340), 5, 110.0, 30.0)

	add_platform(Vector2(8060, 480), 240.0)
	add_checkpoint(Vector2(8060, 432))

	add_wind(Vector2(8340, 260), Vector2(210, -760), 280.0, 540.0)
	add_coin_row(Vector2(8300, 120), 5, 75.0, 45.0)
	add_platform(Vector2(8580, 340), 160.0)
	add_wind(Vector2(8660, 240), Vector2(180, -680), 220.0, 340.0)
	add_ground_run(8880, 240, 5)

	add_npc(
		Vector2(9080, 192),
		"Pasărea Vântului",
		"wind_bird",
		"wind_bird",
		[
			"PASĂREA: Ai învățat că nu poți controla mereu ceea ce se întâmplă, dar poți controla felul în care reacționezi.",
			"JUCĂTORUL: Cu Pana Vântului pot plana peste orice abis! Casa mea e tot mai aproape!"
		],
		[],
		true,
		false,
		"wind_feather"
	)

	add_relic(Vector2(9240, 130), "wind_feather", "PANA VÂNTULUI", "Permite planarea temporară în aer și activează sigiliul din Nivelul 5!")
	add_exit(Vector2(9440, 192))
