extends SceneTree

var events: Array[Dictionary] = []

class NativeStub extends Node:
	var received: Array[Dictionary] = []
	func log_event(event_name: String, parameters: Dictionary) -> void:
		received.append({"name": event_name, "parameters": parameters})

func _initialize() -> void:
	call_deferred("_run")

func _capture(event_name: String, parameters: Dictionary) -> void:
	events.append({"name": event_name, "parameters": parameters})

func _run() -> void:
	var path := "user://analytics_test_record.cfg"
	var initial := ConfigFile.new()
	initial.set_value("record", "seconds", 0.0)
	assert(initial.save(path) == OK)
	var game: Control = load("res://scenes/game.tscn").instantiate()
	game.analytics.record_path = path
	game.analytics.event_recorded.connect(_capture)
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	assert(events.size() == 1 and events[0].name == "game_started")
	game.analytics.track_game_started()
	assert(events.size() == 1)
	for attempt in range(3):
		var duration: float = [2.0, 1.0, 3.0][attempt]
		game.model.survival_time = duration
		game.model.angle_degrees = game.settings.fall_limit_degrees + 1.0
		game._physics_process(0.0)
		assert(events[-1].name == "game_over")
		assert(events[-1].parameters.survival_seconds == duration)
		assert(events[-1].parameters.is_new_record == int(attempt != 1))
		assert(events[-1].parameters.attempt_number == attempt + 1)
		var count: int = events.size()
		for frame in range(30):
			game._physics_process(1.0 / 60.0)
		game.analytics.track_game_over(duration)
		assert(events.size() == count, "No duplicar derrotas por frame ni llamadas repetidas")
		var touch := InputEventScreenTouch.new()
		touch.index = 0
		touch.pressed = true
		Input.parse_input_event(touch)
		Input.flush_buffered_events()
		assert(not game.model.is_game_over and game.model.survival_time == 0.0)
		assert(events.size() == count + 2)
		assert(events[-2].name == "retry" and events[-1].name == "game_started")
		game.analytics.track_retry()
		assert(events.size() == count + 2)
	var restored := AnalyticsService.new()
	restored.record_path = path
	restored.debug_logging = false
	root.add_child(restored)
	assert(restored.best_seconds == 3.0, "Conservar récord entre aperturas")
	restored.event_recorded.connect(_capture)
	restored.track_game_started()
	restored.track_game_over(3.0)
	assert(events[-1].parameters.is_new_record == 0, "Empatar no es récord")
	restored._on_analytics_initialized(false)
	restored.track_retry()
	restored.track_game_started()
	restored.track_game_over(4.0)
	assert(events[-1].parameters.is_new_record == 1, "Fallo del proveedor no afecta eventos locales")
	var native := NativeStub.new()
	root.add_child(native)
	restored._provider = native
	restored.track_retry()
	restored.track_game_started()
	restored.track_game_over(2.0)
	assert(native.received.is_empty(), "Esperar inicialización sin bloquear el juego")
	restored._on_analytics_initialized(true)
	await process_frame
	assert(native.received.size() == 3)
	assert(native.received[0].name == "retry" and native.received[2].name == "game_over")
	restored._on_analytics_initialized(true)
	await process_frame
	assert(native.received.size() == 3, "Inicialización repetida no reenvía la cola")
	native.free()
	restored.free()
	game.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("PASS analytics: orden, parámetros numéricos, récord persistente/empate, deduplicación, retry, proveedor ausente/fallido")
	quit()
