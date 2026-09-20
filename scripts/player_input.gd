extends Node

signal pointer_pressed

var touch_ids: Dictionary = {}
var mouse_held: bool = false
var keyboard_held: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_ids[event.index] = true
			pointer_pressed.emit()
		else:
			touch_ids.erase(event.index)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_held = event.pressed
		if event.pressed:
			pointer_pressed.emit()
	elif event is InputEventKey and event.physical_keycode == KEY_SPACE:
		keyboard_held = event.pressed

func is_pressing() -> bool:
	return mouse_held or keyboard_held or not touch_ids.is_empty()

func clear() -> void:
	touch_ids.clear()
	mouse_held = false
	keyboard_held = false

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		clear()
