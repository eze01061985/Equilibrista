extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _time_to_fall(settings: BalanceSettings, pressing: bool) -> float:
	var model := BalanceModel.new()
	for frame in range(1200):
		model.advance(1.0 / 60.0, pressing, settings)
		if model.is_game_over:
			return model.survival_time
	assert(false, "Debe perder antes de 20 segundos sin dosificar")
	return 0.0

func _run() -> void:
	var settings := BalanceSettings.new()
	var previous := BalanceSettings.new()
	previous.fall_limit_degrees = 25.0
	previous.natural_torque = 1.0
	previous.player_torque = 2.2
	previous.acceleration = 24.0
	previous.damping = 1.4
	for pressing: bool in [false, true]:
		var old_time: float = _time_to_fall(previous, pressing)
		var new_time: float = _time_to_fall(settings, pressing)
		assert(new_time < old_time * 0.7, "El margen de reacción debe ser considerablemente menor")
		print("Tiempo hasta caída (presionado=%s): v0.1 %.2fs / v0.2 %.2fs" % [pressing, old_time, new_time])
	for side: float in [-1.0, 1.0]:
		assert(settings.danger_color(side * settings.fall_limit_degrees * 0.39, false) == settings.safe_color)
		assert(settings.danger_color(side * settings.fall_limit_degrees * 0.41, false) == settings.warning_color)
		assert(settings.danger_color(side * settings.fall_limit_degrees * 0.76, false) == settings.critical_color)
		assert(settings.danger_color(0.0, true) == settings.critical_color)
		var model := BalanceModel.new()
		model.angle_degrees = side * 5.0
		for frame in range(120):
			model.advance(1.0 / 60.0, true, settings)
			if model.angle_degrees * side < 0.0:
				break
		assert(not model.is_game_over and model.angular_velocity * side < -15.0, "Debe atravesar el centro con inercia")
		var speed: float = absf(model.angular_velocity)
		model.advance(1.0 / 60.0, false, settings)
		assert(absf(model.angular_velocity) >= speed * 0.98, "Soltar no debe frenar de golpe")
		model.angular_velocity = side * settings.max_angular_speed * 2.0
		model.advance(1.0 / 60.0, false, settings)
		assert(absf(model.angular_velocity) <= settings.max_angular_speed)
	var game: Control = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	for ratio: float in [0.0, 0.55, 0.9, 1.01]:
		game._restart()
		game.model.angle_degrees = game.settings.fall_limit_degrees * ratio
		game._physics_process(0.0)
		game.game_view.update_feedback(1.0 if ratio < 1.0 else 0.0)
		if ratio > 1.0:
			assert(game.ui.status_label.text == "Perdiste el equilibrio")
			assert(game.game_view.bar_color == settings.critical_color)
			assert(game.game_view.loss_elapsed == 0.0)
		if DisplayServer.get_name() != "headless":
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("user://v02-%d.png" % int(ratio * 100))
	game.game_view.update_feedback(settings.loss_flash_seconds + 0.01)
	assert(game.game_view.loss_elapsed > settings.loss_flash_seconds, "El flash debe terminar sin repetirse")
	game._restart()
	assert(game.game_view.loss_elapsed == 0.0 and game.game_view.bar_color == settings.safe_color)
	print("PASS v0.2: dificultad comparada, inercia, velocidad máxima, colores simétricos, flash breve y reinicio")
	quit()
