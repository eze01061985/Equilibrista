extends Control

signal retry_requested
var timer_label: Label
var status_label: Label
var retry_button: Button

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var header := VBoxContainer.new()
	header.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	header.offset_top = 64
	header.add_theme_constant_override("separation", 12)
	add_child(header)
	header.add_child(_label("E Q U I L I B R I S T A", 23))
	timer_label = _label("0.0 s", 54)
	header.add_child(timer_label)
	header.add_child(_label("Dosificá los toques para mantener el equilibrio", 17))
	var footer := VBoxContainer.new()
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_top = -225
	footer.offset_bottom = -40
	footer.add_theme_constant_override("separation", 16)
	add_child(footer)
	status_label = _label("Mantené para inclinar a la derecha\nAl soltar, cae hacia el lado inclinado", 21)
	footer.add_child(status_label)
	footer.add_child(_label("TOUCH  /  CLICK  /  ESPACIO", 15))
	retry_button = Button.new()
	retry_button.text = "Volver a intentar"
	retry_button.custom_minimum_size = Vector2(260, 62)
	retry_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	retry_button.add_theme_font_size_override("font_size", 23)
	retry_button.focus_mode = Control.FOCUS_NONE
	retry_button.pressed.connect(func() -> void: retry_requested.emit())
	footer.add_child(retry_button)
	retry_button.hide()

func update_run(time: float, game_over: bool) -> void:
	timer_label.text = "%.1f s" % time
	retry_button.visible = game_over
	status_label.text = "Perdiste el equilibrio" if game_over else "Mantené para inclinar a la derecha\nAl soltar, cae hacia el lado inclinado"

func _label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

