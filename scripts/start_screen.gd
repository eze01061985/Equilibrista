extends Control

var play_button: Button
var header: VBoxContainer
var footer: VBoxContainer
var starting := false

func _ready() -> void:
	var illustration := preload("res://scripts/game_view.gd").new()
	illustration.settings = BalanceSettings.new()
	illustration.limit_degrees = illustration.settings.fall_limit_degrees
	illustration.reset_feedback()
	illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(illustration)
	illustration.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	header = VBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_constant_override("separation", 16)
	add_child(header)
	header.add_child(Presentation.label("Equilibrista", 46))
	header.add_child(Presentation.label("Mantén el equilibrio", 23, Presentation.MUTED))
	footer = VBoxContainer.new()
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(footer)
	play_button = Presentation.button("JUGAR")
	play_button.pressed.connect(_play)
	footer.add_child(play_button)
	resized.connect(_layout)
	_layout.call_deferred()

func _layout() -> void:
	var safe := Presentation.safe_rect(size)
	header.position = safe.position + Vector2(0, safe.size.y * 0.10)
	header.size = Vector2(safe.size.x, 120)
	footer.position = Vector2(safe.position.x, safe.end.y - 136)
	footer.size = Vector2(safe.size.x, 76)

func _input(event: InputEvent) -> void:
	# No emulamos mouse desde touch: el botón recibe el toque explícitamente.
	if event is InputEventScreenTouch and event.pressed and play_button.get_global_rect().has_point(event.position):
		get_viewport().set_input_as_handled()
		_play()

func _play() -> void:
	if starting:
		return
	starting = true
	play_button.disabled = true
	var error := get_tree().change_scene_to_file("res://scenes/game.tscn")
	if error != OK:
		starting = false
		play_button.disabled = false
		push_error("No se pudo abrir la partida: %s" % error)
