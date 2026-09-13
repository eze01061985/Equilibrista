class_name BalanceModel
extends RefCounted

var angle_degrees: float = 0.0
var angular_velocity: float = 0.0
var survival_time: float = 0.0
var is_game_over: bool = false

func reset() -> void:
	angle_degrees = 0.0
	angular_velocity = 0.0
	survival_time = 0.0
	is_game_over = false

func advance(delta: float, pressing: bool, settings: BalanceSettings) -> void:
	if is_game_over:
		return
	var torque: float = -settings.natural_left_torque
	if pressing:
		torque += settings.player_right_torque * settings.sensitivity
	angular_velocity += torque * settings.acceleration * delta
	angular_velocity /= 1.0 + settings.damping * delta
	angle_degrees += angular_velocity * delta
	survival_time += delta
	is_game_over = absf(angle_degrees) >= settings.fall_limit_degrees
