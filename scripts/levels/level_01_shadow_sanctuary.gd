extends LevelBase

func _build_level() -> void:
	level_number = 1
	level_width = 10300.0
	fall_death_y = 1050.0
	camera_top_limit = -600
	if spawn_point:
		spawn_point.position = Vector2(120, 520)

	add_ground_run(100, 580, 5)
	add_decor(Vector2(180, 532), "ruin_arch")

	add_npc(
		Vector2(360, 532),
		"Licuriciul Magic",
		"firefly",
		"firefly",
		[
			"LICURICIUL: Bine ai venit în Sanctuarul Umbrelor! Drumul spre casă începe aici.",
			"JUCĂTORUL: Nu știu cum am ajuns aici... Trebuie să găsesc o cale spre casă.",
			"LICURICIUL: Atunci privește cu atenție. Uneori, cele mai importante lucruri sunt ascunse."
		],
		[],
		true,
		true
	)

	add_platform(Vector2(860, 520), 160.0)
	add_platform(Vector2(1060, 470), 160.0)
	add_platform(Vector2(1240, 520), 160.0)
	add_coin(Vector2(560, 510))
	add_coin(Vector2(660, 510))
	add_coin(Vector2(860, 450))
	add_coin(Vector2(1060, 400))
	add_coin(Vector2(1240, 450))
	add_decor(Vector2(1060, 422), "glow_flora", "", "", Color(0.75, 0.35, 1.0))

	add_ground_run(1420, 560, 3)
	add_crate(Vector2(1500, 512), 2)
	add_crate(Vector2(1555, 512), 3)
	add_enemy_caterpillar(Vector2(1700, 500), 80.0, 55.0)

	add_platform(Vector2(1940, 520), 180.0)
	add_spikes(Vector2(1940, 472))
	add_coin_row(Vector2(1890, 410), 3, 45.0, 25.0)

	add_ground_run(2160, 560, 4)
	add_crate(Vector2(2220, 512), 2)
	add_enemy_snail(Vector2(2360, 500), 90.0, 42.0)
	add_decor(Vector2(2480, 512), "torch", "", "", Color(0.95, 0.35, 0.55))

	add_platform(Vector2(1740, 400), 130.0)
	add_platform(Vector2(1920, 290), 140.0)
	add_platform(Vector2(2140, 210), 220.0)
	add_decor(Vector2(2140, 162), "ruin_arch")
	add_star(Vector2(2140, 140), "l1_star_ruins")
	add_coin_row(Vector2(2070, 150), 3, 65.0, 0.0)

	add_platform(Vector2(2680, 540), 180.0)
	add_checkpoint(Vector2(2680, 492))

	add_ground_run(2880, 540, 4)
	add_decor(Vector2(3180, 492), "torch", "", "", Color(1.0, 0.85, 0.3))
	add_decor(Vector2(3340, 492), "torch", "", "", Color(1.0, 0.85, 0.3))

	add_platform(Vector2(2840, 660), 140.0)
	add_platform(Vector2(2680, 750), 140.0)

	add_platform(Vector2(2460, 830), 320.0)
	add_decor(Vector2(2360, 782), "ruin_arch")
	var secret_portal := SecretPortal.new()
	secret_portal.position = Vector2(2460, 782)
	secret_portal.target_position = Vector2(7580, 260)
	secret_portal.banner_title = "AI DESCOPERIT SCURTĂTURA SECRETĂ!"
	secret_portal.banner_subtitle = "Uneori drumul care pare greșit este cel corect."
	add_child(secret_portal)

	add_platform(Vector2(3580, 520), 160.0)
	add_crumbling(Vector2(3760, 520), 0.45)
	add_platform(Vector2(3940, 500), 160.0)
	add_spikes(Vector2(3940, 452))
	add_coin_row(Vector2(3720, 440), 4, 55.0, 20.0)
	add_crumbling(Vector2(4120, 500), 0.45)
	add_platform(Vector2(4300, 500), 180.0)

	add_ground_run(4500, 520, 5)
	add_blade(Vector2(4560, 460), Vector2(140, 0), 2.0)
	add_retractable_spikes(Vector2(4780, 472), 2.6, 0.0)
	add_retractable_spikes(Vector2(4840, 472), 2.6, 1.3)
	add_crate(Vector2(4940, 472), 3)
	add_enemy_caterpillar(Vector2(5040, 460), 75.0, 65.0)
	add_coin_row(Vector2(4580, 390), 5, 60.0, 25.0)
	add_checkpoint(Vector2(5160, 472))

	add_platform(Vector2(5340, 480), 150.0)
	add_platform(Vector2(5520, 380), 140.0)
	add_platform(Vector2(5340, 270), 140.0)
	add_platform(Vector2(5540, 170), 160.0)
	add_star(Vector2(5540, 100), "l1_star_tower")
	add_coin_row(Vector2(5310, 210), 3, 40.0, 0.0)
	add_platform(Vector2(5760, 280), 150.0)
	add_platform(Vector2(5940, 400), 160.0)

	add_ground_run(6140, 480, 5)
	add_enemy_guardian(Vector2(6300, 420), 95.0)
	add_platform(Vector2(6460, 350), 130.0)
	add_coin_row(Vector2(6410, 290), 3, 48.0, 0.0)
	add_enemy_guardian(Vector2(6620, 420), 95.0)
	add_checkpoint(Vector2(6780, 432))

	add_moving_platform(Vector2(6980, 460), Vector2(160, 0), 2.4)
	add_coin_row(Vector2(7020, 390), 3, 50.0, 20.0)
	add_platform(Vector2(7320, 460), 140.0)
	add_spikes(Vector2(7320, 412))
	add_moving_platform(Vector2(7520, 480), Vector2(180, 0), 2.5)
	add_platform(Vector2(7880, 500), 180.0)
	add_moving_platform(Vector2(8120, 500), Vector2(170, -20), 2.4)

	add_platform(Vector2(7600, 320), 220.0)
	add_decor(Vector2(7540, 272), "glow_flora", "", "", Color(0.95, 0.45, 1.0))
	add_decor(Vector2(7660, 272), "glow_flora", "", "", Color(0.45, 0.9, 1.0))
	add_star(Vector2(7660, 230), "l1_star_portal_1")
	add_coin_row(Vector2(7540, 250), 3, 48.0, 0.0)

	add_platform(Vector2(7860, 320), 160.0)
	add_flower(Vector2(7900, 272), 720.0)
	add_platform(Vector2(8120, 170), 180.0)
	add_decor(Vector2(8120, 122), "glow_flora", "", "", Color(1.0, 0.85, 0.35))
	add_star(Vector2(8120, 95), "l1_star_portal_2")
	add_coin_row(Vector2(8060, 110), 3, 55.0, 0.0)
	add_platform(Vector2(8340, 310), 160.0)

	add_ground_run(8520, 480, 6)
	add_checkpoint(Vector2(8540, 432))
	add_decor(Vector2(8640, 432), "ruin_arch")
	add_enemy_snail(Vector2(8820, 420), 85.0, 45.0)
	add_flower(Vector2(8980, 432), 680.0)
	add_platform(Vector2(9180, 320), 180.0)
	add_relic(Vector2(9180, 240), "shadow_emblem", "EMBLEMA UMBRELOR", "Primul simbol antic pentru deschiderea Porții Sanctuarului!")
	add_coin_row(Vector2(8700, 390), 5, 55.0, 20.0)

	add_ground_run(9520, 420, 4)
	add_decor(Vector2(9560, 372), "torch", "", "", Color(1.0, 0.88, 0.35))
	add_decor(Vector2(9860, 372), "torch", "", "", Color(1.0, 0.88, 0.35))

	add_npc(
		Vector2(9680, 372),
		"Licuriciul Magic",
		"firefly",
		"firefly",
		[
			"LICURICIUL: Ai reușit! Ai învățat că nu întotdeauna drumul cel mai evident este cel mai bun.",
			"JUCĂTORUL: Cred că încep să înțeleg ce înseamnă Bounce Back!"
		],
		[],
		true,
		false
	)

	add_exit(Vector2(9920, 372))
