class_name BalanceSettings
extends Resource

@export_range(1.0, 90.0, 0.5) var fall_limit_degrees: float = 25.0
@export_range(0.1, 5.0, 0.05) var natural_left_torque: float = 1.0
@export_range(0.1, 10.0, 0.05) var player_right_torque: float = 2.2
@export_range(1.0, 120.0, 1.0) var acceleration: float = 24.0
@export_range(0.1, 3.0, 0.05) var sensitivity: float = 1.0
@export_range(0.0, 5.0, 0.05) var damping: float = 1.4
