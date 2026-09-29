extends Control

const PRIVACY_URL := "https://eze01061985.github.io/Equilibrista/privacy/"

var privacy_link: LinkButton
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
	privacy_link = LinkButton.new()
	privacy_link.text = "Política de privacidad"
	privacy_link.custom_minimum_size.y = 44
	privacy_link.add_theme_font_size_override("font_size", 18)
	privacy_link.add_theme_color_override("font_color", Presentation.MUTED)
	privacy_link.pressed.connect(_open_privacy)
	add_child(privacy_link)
	resized.connect(_layout)
	_layout.call_deferred()

func _layout() -> void:
	var safe := Presentation.safe_rect(size)
	header.position = safe.position + Vector2(0, safe.size.y * 0.10)
	header.size = Vector2(safe.size.x, 120)
	footer.position = Vector2(safe.position.x, safe.end.y - 136)
	footer.size = Vector2(safe.size.x, 76)
	privacy_link.size = privacy_link.get_combined_minimum_size()
	privacy_link.position = Vector2(safe.position.x + (safe.size.x - privacy_link.size.x) / 2.0, safe.end.y - 44)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed and privacy_link.get_global_rect().has_point(event.position):
		get_viewport().set_input_as_handled()
		_open_privacy()
		return
	# No emulamos mouse desde touch: el botón recibe el toque explícitamente.
	if event is InputEventScreenTouch and event.pressed and play_button.get_global_rect().has_point(event.position):
		get_viewport().set_input_as_handled()
		_play()

func _open_privacy() -> void:
	var error := OS.shell_open(PRIVACY_URL)
	if error != OK:
		push_warning("No se pudo abrir la política de privacidad: %s" % error)

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
