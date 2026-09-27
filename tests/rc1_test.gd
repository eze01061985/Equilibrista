extends SceneTree

var events: Array[String] = []
const TEST_RECORD := "user://rc1_test_record.cfg"

func _initialize() -> void:
	call_deferred("_run")

func _pointer(touch: bool, pressed: bool, position: Vector2) -> void:
	var event: InputEvent
	if touch:
		var input := InputEventScreenTouch.new()
		input.index = 0
		input.position = position
		input.pressed = pressed
		event = input
	else:
		var input := InputEventMouseButton.new()
		input.button_index = MOUSE_BUTTON_LEFT
		input.position = position
		input.pressed = pressed
		event = input
	root.push_input(event, true)

func _capture(tag: String) -> void:
	await process_frame
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("user://rc1-%s.png" % tag)

func _check_ui(node: Node, bounds: Rect2) -> void:
	for child in node.get_children():
		if child is Control and child.is_visible_in_tree() and (child is Label or child is Button):
			assert(bounds.grow(1.0).encloses(child.get_global_rect()), "Texto/botón fuera de pantalla: %s" % child.text)
			assert(child.size.y >= child.get_minimum_size().y, "Texto cortado: %s" % child.text)
		_check_ui(child, bounds)

func _run() -> void:
	root.content_scale_size = Vector2i(540, 960)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	for touch in [false, true]:
		root.size = Vector2i(432, 768)
		var menu: Control = load("res://scenes/start.tscn").instantiate()
		root.add_child(menu)
		current_scene = menu
		await process_frame
		await process_frame
		assert(menu.play_button.text == "JUGAR")
		_pointer(touch, true, Vector2(20, 20))
		_pointer(touch, false, Vector2(20, 20))
		assert(current_scene == menu and not menu.starting, "Solo JUGAR inicia la partida")
		for dimensions: Vector2i in [Vector2i(360, 640), Vector2i(360, 800), Vector2i(768, 1024)]:
			root.size = dimensions
			await _capture("menu-%dx%d" % [dimensions.x, dimensions.y])
			_check_ui(menu, Presentation.safe_rect(menu.size))
		var button_center: Vector2 = menu.play_button.get_global_rect().get_center()
		_pointer(touch, true, button_center)
		_pointer(touch, false, button_center)
		await process_frame
		await process_frame
		var game: Control = current_scene
		assert(game != menu and game.analytics.attempt_number == 1)
		game.set_physics_process(false)
		game.analytics.record_path = TEST_RECORD
		game.analytics.best_seconds = 0.0
		game.ui.set_record(0.0)
		game.analytics.debug_logging = false
		game.analytics.event_recorded.connect(func(event_name: String, _parameters: Dictionary) -> void: events.append(event_name))
		assert(not game.player_input.is_pressing(), "JUGAR no debe dejar corrección presionada")
		assert(not game.model.is_game_over)
		for dimensions: Vector2i in [Vector2i(360, 640), Vector2i(360, 800), Vector2i(768, 1024)]:
			root.size = dimensions
			await _capture("playing-%dx%d" % [dimensions.x, dimensions.y])
			_check_ui(game.ui, Presentation.safe_rect(game.size))
		for attempt in range(3):
			var duration: float = [12.3, 2.0, 14.5][attempt]
			game.model.survival_time = duration
			game.model.angle_degrees = game.settings.fall_limit_degrees + 1.0
			game._physics_process(0.0)
			assert(game.model.is_game_over)
			assert(game.ui.new_record_label.visible == (attempt != 1))
			assert(game.ui.result_label.text.contains("Tiempo: %.1f s" % duration))
			assert(game.ui.result_label.text.contains("Récord: %.1f s" % game.analytics.best_seconds))
			assert(game.audio.record_sound.get_length() > 0.0)
			game._physics_process(1.0) # Verificar también el resultado después de la animación de caída.
			for dimensions: Vector2i in [Vector2i(360, 640), Vector2i(360, 800), Vector2i(768, 1024)]:
				root.size = dimensions
				await _capture("over-%d-%dx%d" % [attempt, dimensions.x, dimensions.y])
				_check_ui(game.ui, Presentation.safe_rect(game.size))
			var previous_count := events.size()
			_pointer(touch, true, Vector2(30, 30))
			_pointer(touch, false, Vector2(30, 30))
			assert(not game.model.is_game_over and game.model.survival_time == 0.0)
			assert(not game.player_input.is_pressing() and not game.ui.new_record_label.visible)
			assert(events.size() == previous_count + 2)
			assert(events[-2] == "retry" and events[-1] == "game_started")
		game.audio.stop()
		game.queue_free()
		await process_frame
		await process_frame
	var saved := ConfigFile.new()
	assert(saved.load(TEST_RECORD) == OK and is_equal_approx(saved.get_value("record", "seconds"), 14.5))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_RECORD))
	print("PASS RC1: JUGAR mouse/touch, 3 relaciones de aspecto, récord/nuevo récord, 6 derrotas y reintentos, eventos sin duplicados")
	print("Capturas: ", ProjectSettings.globalize_path("user://"))
	await create_timer(0.4).timeout
	quit()
