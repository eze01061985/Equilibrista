extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _send_pointer(touch: bool, pressed: bool) -> void:
	var event: InputEvent
	if touch:
		var screen_touch := InputEventScreenTouch.new()
		screen_touch.index = 0
		screen_touch.position = Vector2(30, 30)
		screen_touch.pressed = pressed
		event = screen_touch
	else:
		var mouse := InputEventMouseButton.new()
		mouse.button_index = MOUSE_BUTTON_LEFT
		mouse.position = Vector2(30, 30)
		mouse.pressed = pressed
		event = mouse
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func _run() -> void:
	var game: Control = load("res://scenes/game.tscn").instantiate()
	game.analytics.record_path = "user://regression_test_record.cfg"
	game.analytics.debug_logging = false
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	for touch: bool in [false, true]:
		for spam: bool in [false, true]:
			game._restart()
			var correction_budget: float = 0.0
			var delta: float = 1.0 / 120.0
			for frame in range(60):
				# Ambos casos suman 250 ms presionados dentro de 500 ms.
				var pressing: bool = frame % 6 < 3 if spam else frame < 30
				var velocity_before: float = game.model.angular_velocity
				var direction_before: float = game.model.push_direction
				_send_pointer(touch, pressing)
				_send_pointer(touch, pressing)
				assert(game.model.angular_velocity == velocity_before, "Un evento no debe agregar impulso")
				assert(game.model.push_direction == direction_before, "Los eventos solos no deben modificar la simulación")
				var natural_direction: float = game.model.fall_direction
				if game.model.angle_degrees != 0.0:
					natural_direction = signf(game.model.angle_degrees)
				game._physics_process(delta)
				assert(not game.model.is_game_over)
				var acceleration_applied: float = (game.model.angular_velocity * (1.0 + game.settings.damping * delta) - velocity_before) / delta
				var player_acceleration: float = acceleration_applied - natural_direction * game.settings.natural_torque * game.settings.acceleration
				correction_budget += absf(player_acceleration) * delta
			var expected: float = game.settings.player_torque * game.settings.sensitivity * game.settings.acceleration * 0.25
			assert(absf(correction_budget - expected) < 0.0001, "El presupuesto de fuerza depende solo del tiempo presionado")
			_send_pointer(touch, false)
		for period in [2, 4, 6, 12]:
			game._restart()
			for frame in range(7200):
				_send_pointer(touch, frame % period < period / 2)
				game._physics_process(1.0 / 60.0)
				if game.model.is_game_over:
					break
			assert(game.model.is_game_over and game.model.survival_time < 3.0, "El spam periódico no debe estabilizar automáticamente")
			_send_pointer(touch, false)
			_send_pointer(touch, true)
			assert(not game.model.is_game_over and not game.model.has_corrected)
			assert(game.model.survival_time == 0.0 and not game.player_input.is_pressing())
			_send_pointer(touch, false)
	print("PASS: mouse/touch, eventos duplicados sin impulso, igual fuerza total por tiempo presionado, spam y reintento")
	quit()
