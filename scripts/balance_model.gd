class_name BalanceModel
extends RefCounted

var angle_degrees: float = 0.0
var angular_velocity: float = 0.0
var survival_time: float = 0.0
var is_game_over: bool = false
var fall_direction: float = -1.0

func reset() -> void:
	angle_degrees = 0.0
	angular_velocity = 0.0
	survival_time = 0.0
	is_game_over = false
	fall_direction = -1.0

func advance(delta: float, pressing: bool, settings: BalanceSettings) -> void:
	if is_game_over:
		return
	# Al quedar exactamente horizontal, conservar el último lado de inclinación.
	if angle_degrees != 0.0:
		fall_direction = signf(angle_degrees)
	var torque: float = fall_direction * settings.natural_torque
	if pressing:
		torque += settings.player_right_torque * settings.sensitivity
	angular_velocity += torque * settings.acceleration * delta
	angular_velocity /= 1.0 + settings.damping * delta
	angle_degrees += angular_velocity * delta
	survival_time += delta
	is_game_over = absf(angle_degrees) >= settings.fall_limit_degrees
