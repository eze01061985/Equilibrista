class_name Presentation
extends RefCounted

const INK := Color("#edf2fa")
const MUTED := Color("#a6b4c9")
const ACCENT := Color("#f5cf79")

static func label(text: String, font_size: int, color: Color = INK) -> Label:
	var result := Label.new()
	result.text = text
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result

static func button(text: String) -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size = Vector2(300, 76)
	result.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	result.add_theme_font_size_override("font_size", 25)
	for state: String in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = ACCENT.darkened(0.12) if state == "pressed" else ACCENT
		style.set_corner_radius_all(18)
		if state == "focus":
			style.set_border_width_all(3)
			style.border_color = INK
		result.add_theme_stylebox_override(state, style)
	for state: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		result.add_theme_color_override(state, Color("#17243a"))
	return result

static func safe_rect(view_size: Vector2) -> Rect2:
	var start := Vector2(28, 32)
	var end := view_size - Vector2(28, 36)
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		# Píxeles físicos convertidos a unidades del viewport expandido.
		var physical_size := Vector2(DisplayServer.screen_get_size())
		var safe := Rect2(DisplayServer.get_display_safe_area())
		if physical_size.x > 0.0 and physical_size.y > 0.0 and safe.has_area():
			var scale := view_size / physical_size
			start += safe.position * scale
			end -= (physical_size - safe.end) * scale
	return Rect2(start, (end - start).max(Vector2.ONE))
