extends Control

const BAR_HALF_WIDTH: float = 180.0
var angle_degrees: float = 0.0
var limit_degrees: float = 25.0
var pressing: bool = false
var lost: bool = false
var fall_progress: float = 0.0

func _draw() -> void:
	var center: Vector2 = size * Vector2(0.5, 0.52)
	var scale_factor: float = minf(size.x / 540.0, size.y / 800.0)
	draw_set_transform(center, 0.0, Vector2.ONE * scale_factor)
	var muted := Color("#33435d")
	for limit_sign: float in [-1.0, 1.0]:
		var direction := Vector2.RIGHT.rotated(deg_to_rad(limit_degrees * limit_sign))
		draw_line(-direction * 210.0, direction * 210.0, muted, 2.0, true)
	draw_colored_polygon(PackedVector2Array([Vector2(-24, 64), Vector2(24, 64), Vector2(0, 9)]), muted)
	var bar_color := Color("#ff7b7b") if lost else Color("#64e2cb")
	draw_set_transform(center, deg_to_rad(angle_degrees), Vector2.ONE * scale_factor)
	draw_style_box(_bar_style(bar_color), Rect2(-BAR_HALF_WIDTH, -8, BAR_HALF_WIDTH * 2, 16))
	var object_position := Vector2(0, -31)
	if lost:
		object_position += Vector2(signf(angle_degrees) * fall_progress * 240.0, fall_progress * fall_progress * 340.0)
	draw_circle(object_position, 22, Color("#f5cf79"))
	draw_circle(object_position + Vector2(-7, -3), 2.5, Color("#25334b"))
	draw_circle(object_position + Vector2(7, -3), 2.5, Color("#25334b"))
	draw_set_transform(Vector2.ZERO)
	if pressing and not lost:
		draw_circle(center + Vector2(0, 110 * scale_factor), 6, Color("#64e2cb"))

func _bar_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(8)
	return style
