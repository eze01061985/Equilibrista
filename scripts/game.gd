extends Control

@export var settings: BalanceSettings
var model := BalanceModel.new()
@onready var player_input: Node = $PlayerInput
@onready var game_view: Control = $GameView
@onready var ui: Control = $UI

func _ready() -> void:
	game_view.settings = settings
	game_view.limit_degrees = settings.fall_limit_degrees
	game_view.reset_feedback()
	ui.retry_requested.connect(_restart)
	player_input.pointer_pressed.connect(_on_pointer_pressed)

func _on_pointer_pressed() -> void:
	if model.is_game_over:
		_restart()
		# El toque de reintento no debe activar también la UI ni corregir la nueva partida.
		get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	var pressing: bool = player_input.is_pressing()
	model.advance(delta, pressing, settings)
	game_view.angle_degrees = model.angle_degrees
	game_view.limit_degrees = settings.fall_limit_degrees
	game_view.pressing = pressing
	game_view.lost = model.is_game_over
	if model.is_game_over:
		game_view.fall_progress = minf(game_view.fall_progress + delta * 1.6, 1.0)
	game_view.update_feedback(delta)
	ui.update_run(model.survival_time, model.is_game_over)

func _restart() -> void:
	player_input.clear()
	model.reset()
	game_view.angle_degrees = 0.0
	game_view.lost = false
	game_view.pressing = false
	game_view.fall_progress = 0.0
	game_view.reset_feedback()
	game_view.queue_redraw()
	ui.update_run(0.0, false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		set_physics_process(false)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_APPLICATION_RESUMED:
		set_physics_process(true)
