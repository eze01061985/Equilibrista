extends SceneTree

class TestMenu extends "res://scripts/start_screen.gd":
	var opened := 0
	func _open_privacy() -> void:
		opened += 1
		if "--open-browser" in OS.get_cmdline_user_args():
			super._open_privacy()

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(432, 768)
	root.content_scale_size = Vector2i(540, 960)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	var menu := TestMenu.new()
	root.add_child(menu)
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	current_scene = menu
	await process_frame
	await process_frame
	assert(menu.PRIVACY_URL == "https://eze01061985.github.io/Equilibrista/privacy/")
	assert(not menu.privacy_link.get_global_rect().intersects(menu.play_button.get_global_rect()))
	for touch in [false, true]:
		var center := menu.privacy_link.get_global_rect().get_center()
		for pressed in [true, false]:
			if touch:
				var event := InputEventScreenTouch.new()
				event.position = center
				event.pressed = pressed
				root.push_input(event, true)
			else:
				var event := InputEventMouseButton.new()
				event.position = center
				event.button_index = MOUSE_BUTTON_LEFT
				event.pressed = pressed
				root.push_input(event, true)
		await process_frame
		assert(menu.opened == (2 if touch else 1), "Cada click/touch abre una sola vez")
		assert(current_scene == menu and not menu.starting, "Privacidad no inicia una partida")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("user://privacy-menu.png")
	# Volver al menú tras abrir el navegador y jugar sin heredar el toque.
	var center := menu.play_button.get_global_rect().get_center()
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = center
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		root.push_input(event, true)
	await process_frame
	await process_frame
	var game: Control = current_scene
	assert(game != menu and game.analytics.attempt_number == 1)
	game.set_physics_process(false)
	game.analytics.best_seconds = 999999.0 # No escribir el récord real del usuario.
	assert(not game.player_input.is_pressing())
	for step in range(600):
		game._physics_process(1.0 / 60.0)
		if game.model.is_game_over:
			break
	assert(game.model.is_game_over, "La partida puede perderse tras volver del navegador")
	for pressed in [true, false]:
		var event := InputEventScreenTouch.new()
		event.position = Vector2(30, 30)
		event.pressed = pressed
		root.push_input(event, true)
	assert(not game.model.is_game_over and game.analytics.attempt_number == 2)
	assert(not game.player_input.is_pressing())
	game.audio.stop()
	print("PASS privacy: mouse/touch, apertura única, URL y menú intacto")
	quit()
