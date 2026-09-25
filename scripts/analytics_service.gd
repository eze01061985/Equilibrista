class_name AnalyticsService
extends Node

signal event_recorded(event_name: String, parameters: Dictionary)

const RECORD_PATH := "user://analytics_record.cfg"
const MAX_PENDING_EVENTS := 128
var record_path: String = RECORD_PATH
var debug_logging: bool = OS.is_debug_build()
var attempt_number: int = 0
var best_seconds: float = 0.0
var _attempt_active: bool = false
var _retry_available: bool = false
var _provider: Object
var _provider_ready: bool = false
var _pending: Array[Dictionary] = []

func _ready() -> void:
	var saved := ConfigFile.new()
	if saved.load(record_path) == OK:
		var value: Variant = saved.get_value("record", "seconds", 0.0)
		if (value is float or value is int) and is_finite(float(value)):
			best_seconds = maxf(0.0, float(value))
	if OS.get_name() != "Android" or not Engine.has_singleton("GodotxFirebaseCore") or not Engine.has_singleton("GodotxFirebaseAnalytics"):
		return
	var core: Object = Engine.get_singleton("GodotxFirebaseCore")
	_provider = Engine.get_singleton("GodotxFirebaseAnalytics")
	core.connect("core_initialized", _on_core_initialized)
	_provider.connect("analytics_initialized", _on_analytics_initialized)
	core.call_deferred("initialize")

func track_game_started() -> void:
	if _attempt_active:
		return
	attempt_number += 1
	_attempt_active = true
	_retry_available = false
	_track("game_started", {"attempt_number": attempt_number})

func track_game_over(survival_seconds: float) -> void:
	if not _attempt_active:
		return
	_attempt_active = false
	_retry_available = true
	var duration: float = maxf(0.0, survival_seconds) if is_finite(survival_seconds) else 0.0
	var is_new_record: bool = duration > best_seconds
	if is_new_record:
		best_seconds = duration
		var saved := ConfigFile.new()
		saved.set_value("record", "seconds", best_seconds)
		var result: Error = saved.save(record_path)
		if result != OK and debug_logging:
			print("[Analytics] No se pudo guardar el récord; el juego continúa.")
	_track("game_over", {"survival_seconds": duration, "is_new_record": int(is_new_record), "attempt_number": attempt_number})

func track_retry() -> void:
	if not _retry_available:
		return
	_retry_available = false
	_track("retry", {"attempt_number": attempt_number})

func _track(event_name: String, parameters: Dictionary) -> void:
	if debug_logging:
		print("[Analytics] ", event_name, " ", JSON.stringify(parameters))
	event_recorded.emit(event_name, parameters.duplicate())
	if _provider_ready:
		_provider.call_deferred("log_event", event_name, parameters)
	elif _provider != null and _pending.size() < MAX_PENDING_EVENTS:
		_pending.append({"name": event_name, "parameters": parameters})

func _on_core_initialized(success: bool) -> void:
	if success:
		_provider.call_deferred("initialize")
	else:
		_pending.clear()
		_provider = null

func _on_analytics_initialized(success: bool) -> void:
	_provider_ready = success
	if success:
		for event in _pending:
			_provider.call_deferred("log_event", event.name, event.parameters)
	else:
		_provider = null
	_pending.clear()
