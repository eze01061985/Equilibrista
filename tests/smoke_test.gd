extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var settings := BalanceSettings.new()
	for pressing: bool in [false, true]:
		var model := BalanceModel.new()
		for frame in range(600):
			model.advance(1.0 / 60.0, pressing, settings)
		assert(model.is_game_over, "Debe caer en ambos sentidos")
		assert((model.angle_degrees > 0) == pressing, "Dirección de caída incorrecta")
		var final_time: float = model.survival_time
		model.advance(1.0, pressing, settings)
		assert(model.survival_time == final_time, "El reloj debe detenerse")
		model.reset()
		assert(model.survival_time == 0.0 and model.angle_degrees == 0.0 and not model.is_game_over)
	for side: float in [-1.0, 1.0]:
		var released := BalanceModel.new()
		released.angle_degrees = side * 5.0
		released.advance(1.0 / 60.0, false, settings)
		assert(released.angular_velocity * side > 0.0, "Soltar debe acelerar hacia el lado inclinado")
		released.angle_degrees = 0.0
		released.angular_velocity = 0.0
		released.advance(1.0 / 60.0, false, settings)
		assert(released.angular_velocity * side > 0.0, "Horizontal debe recordar el último lado")
		released.reset()
		released.advance(1.0 / 60.0, false, settings)
		assert(released.angle_degrees < 0.0, "Reiniciar debe recuperar la caída inicial izquierda")
	var overshoot := BalanceModel.new()
	overshoot.angle_degrees = -5.0
	for frame in range(60):
		overshoot.advance(1.0 / 60.0, true, settings)
	assert(overshoot.angle_degrees > 0.0 and not overshoot.is_game_over)
	for frame in range(600):
		overshoot.advance(1.0 / 60.0, false, settings)
	assert(overshoot.is_game_over and overshoot.angle_degrees > 0.0, "Pasarse y soltar debe terminar en caída derecha")
	var controlled := BalanceModel.new()
	for frame in range(3600):
		var correction: bool = controlled.angle_degrees + controlled.angular_velocity * 0.5 < -3.0
		controlled.advance(1.0 / 60.0, correction, settings)
	assert(not controlled.is_game_over, "Las correcciones deben permitir sostener el equilibrio")
	var game: Control = load("res://scenes/game.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.pressed = true
	Input.parse_input_event(touch.duplicate())
	Input.flush_buffered_events()
	assert(game.player_input.is_pressing(), "Touch debe activar el torque")
	touch.pressed = false
	Input.parse_input_event(touch.duplicate())
	Input.flush_buffered_events()
	assert(not game.player_input.is_pressing(), "Soltar touch debe detener el torque")
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = true
	Input.parse_input_event(mouse.duplicate())
	Input.flush_buffered_events()
	assert(game.player_input.is_pressing())
	mouse.pressed = false
	Input.parse_input_event(mouse.duplicate())
	Input.flush_buffered_events()
	var key := InputEventKey.new()
	key.physical_keycode = KEY_SPACE
	key.pressed = true
	Input.parse_input_event(key)
	Input.flush_buffered_events()
	assert(game.player_input.is_pressing())
	game.player_input.clear()
	for frame in range(600):
		game._physics_process(1.0 / 60.0)
	assert(game.ui.retry_button.visible)
	game.ui.retry_button.pressed.emit()
	assert(not game.model.is_game_over and game.model.survival_time == 0.0)
	assert(not game.ui.retry_button.visible and not game.player_input.is_pressing())
	if DisplayServer.get_name() != "headless":
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("user://smoke-test.png")
	print("PASS: caída izquierda/derecha, reloj, control 60s, touch, mouse, espacio y reintento")
	quit()


