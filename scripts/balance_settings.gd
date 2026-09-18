class_name BalanceSettings
extends Resource

@export_group("Gameplay")
@export_range(1.0, 90.0, 0.5) var fall_limit_degrees: float = 14.0
@export_range(0.1, 5.0, 0.05) var natural_torque: float = 1.2
@export_range(0.1, 10.0, 0.05) var player_torque: float = 3.4
@export_range(1.0, 120.0, 1.0) var acceleration: float = 32.0
@export_range(0.1, 3.0, 0.05) var sensitivity: float = 1.0
@export_range(0.0, 5.0, 0.05) var damping: float = 0.45
@export_range(10.0, 360.0, 1.0) var max_angular_speed: float = 90.0

@export_group("Danger Feedback")
@export_range(0.01, 0.98, 0.01) var warning_ratio: float = 0.4
@export_range(0.02, 0.99, 0.01) var critical_ratio: float = 0.75
@export var safe_color: Color = Color("#64e2a0")
@export var warning_color: Color = Color("#f5cf59")
@export var critical_color: Color = Color("#ff6565")
@export_range(0.0, 0.3, 0.01) var color_transition_seconds: float = 0.08
@export_range(0.05, 0.5, 0.01) var loss_flash_seconds: float = 0.18
@export_range(0.0, 0.25, 0.01) var loss_flash_opacity: float = 0.12

func danger_color(angle: float, game_over: bool) -> Color:
	if game_over:
		return critical_color
	var ratio: float = absf(angle) / maxf(fall_limit_degrees, 0.01)
	# Mantener umbrales ordenados aun si se editan en orden inverso.
	var critical_start: float = maxf(critical_ratio, warning_ratio + 0.01)
	if ratio >= critical_start:
		return critical_color
	if ratio >= warning_ratio:
		return warning_color
	return safe_color
