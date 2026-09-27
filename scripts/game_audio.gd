class_name GameAudio
extends AudioStreamPlayer

var start_sound: AudioStreamWAV
var over_sound: AudioStreamWAV
var record_sound: AudioStreamWAV

func _ready() -> void:
	volume_db = -18.0
	start_sound = _tone([440.0, 660.0], 0.085)
	over_sound = _tone([240.0, 160.0], 0.12)
	record_sound = _tone([523.25, 659.25, 783.99], 0.12)

func play_start() -> void:
	_play_sound(start_sound)

func play_result(new_record: bool) -> void:
	_play_sound(record_sound if new_record else over_sound)

func _play_sound(sound: AudioStreamWAV) -> void:
	# En pruebas sin ventana no hay salida de audio; el driver dummy no mezcla los buffers.
	if DisplayServer.get_name() == "headless":
		return
	stream = sound
	play()

func _tone(notes: Array[float], seconds_per_note: float) -> AudioStreamWAV:
	# Tonos propios con envolvente suave para evitar clics, sin archivos externos.
	const RATE := 22050
	var samples_per_note := int(RATE * seconds_per_note)
	var data := PackedByteArray()
	data.resize(samples_per_note * notes.size() * 2)
	for note in range(notes.size()):
		for sample in range(samples_per_note):
			var progress := float(sample) / samples_per_note
			var envelope := sin(PI * progress) * (1.0 - progress)
			var wave := sin(TAU * notes[note] * sample / RATE)
			data.encode_s16((note * samples_per_note + sample) * 2, int(wave * envelope * 18000.0))
	var sound := AudioStreamWAV.new()
	sound.format = AudioStreamWAV.FORMAT_16_BITS
	sound.mix_rate = RATE
	sound.data = data
	return sound
