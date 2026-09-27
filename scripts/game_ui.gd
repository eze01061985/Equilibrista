extends Control

signal retry_requested
var timer_label: Label
var status_label: Label
var retry_button: Button
var record_label: Label
var result_label: Label
var new_record_label: Label
var header: VBoxContainer
var footer: VBoxContainer
var playing_hint: Label
var result_panel: Panel
var record_seconds := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	header = VBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_constant_override("separation", 8)
	add_child(header)
	header.add_child(Presentation.label("Equilibrista", 25, Presentation.MUTED))
	timer_label = Presentation.label("0.0 s", 64)
	header.add_child(timer_label)
	record_label = Presentation.label("Récord: 0.0 s", 22, Presentation.MUTED)
	header.add_child(record_label)
	result_panel = Panel.new()
	result_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var card := StyleBoxFlat.new()
	card.bg_color = Color("#101b2b")
	card.border_color = Color("#25334b")
	card.set_border_width_all(1)
	card.set_corner_radius_all(20)
	result_panel.add_theme_stylebox_override("panel", card)
	add_child(result_panel)
	footer = VBoxContainer.new()
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.add_theme_constant_override("separation", 10)
	add_child(footer)
	status_label = Presentation.label("", 28)
	footer.add_child(status_label)
	result_label = Presentation.label("", 23, Presentation.MUTED)
	footer.add_child(result_label)
	new_record_label = Presentation.label("¡NUEVO RÉCORD!", 23, Presentation.ACCENT)
	footer.add_child(new_record_label)
	playing_hint = Presentation.label("Mantén para corregir\nSuelta a tiempo", 23, Presentation.MUTED)
	footer.add_child(playing_hint)
	retry_button = Presentation.button("Toca para reintentar")
	retry_button.focus_mode = Control.FOCUS_NONE
	retry_button.pressed.connect(func() -> void: retry_requested.emit())
	footer.add_child(retry_button)
	resized.connect(_layout)
	update_run(0.0, false)
	_layout.call_deferred()

func _layout() -> void:
	var safe := Presentation.safe_rect(size)
	header.position = safe.position
	header.size = Vector2(safe.size.x, 160)
	footer.position = Vector2(safe.position.x, safe.end.y - 244)
	footer.size = Vector2(safe.size.x, 244)
	result_panel.position = footer.position - Vector2(0, 14)
	result_panel.size = footer.size + Vector2(0, 28)

func set_record(seconds: float, new_record: bool = false) -> void:
	record_seconds = seconds
	record_label.text = "Récord: %.1f s" % seconds
	new_record_label.visible = new_record

func update_run(time: float, game_over: bool) -> void:
	timer_label.text = "%.1f s" % time
	timer_label.visible = not game_over
	record_label.visible = not game_over
	retry_button.visible = game_over
	result_panel.visible = game_over
	status_label.visible = game_over
	result_label.visible = game_over
	playing_hint.visible = not game_over
	status_label.text = "Perdiste el equilibrio" if game_over else ""
	result_label.text = "Tiempo: %.1f s\nRécord: %.1f s" % [time, record_seconds]
	if not game_over:
		new_record_label.hide()
