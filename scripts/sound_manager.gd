extends AudioStreamPlayer
class_name SoundManager

var _pending_samples: Array[Vector2] = []

func _process(_delta):
	if not is_playing():
		return
	var pb = get_stream_playback()
	if pb == null:
		return
	while _pending_samples.size() > 0:
		var frame = _pending_samples.pop_front()
		var success = pb.push_frame(frame)
		if not success:
			_pending_samples.push_front(frame)
			break

func play_match():
	var samples: Array[Vector2] = []
	for i in range(4410):
		var t = float(i) / 44100.0
		var env = max(0.0, 1.0 - t / 0.1)
		var freq = 880.0
		samples.append(Vector2(
			sin(TAU * freq * t) * env * 0.3,
			sin(TAU * freq * t * 1.5) * env * 0.15
		))
	_start_playback(samples)

func play_miss():
	var samples: Array[Vector2] = []
	for i in range(6615):
		var t = float(i) / 44100.0
		var env = max(0.0, 1.0 - t / 0.15)
		var sweep = 220.0 * (1.0 - t * 3.0)
		samples.append(Vector2(
			sin(TAU * sweep * t) * env * 0.4,
			sin(TAU * sweep * t * 0.7) * env * 0.24
		))
	_start_playback(samples)

func play_game_over():
	var samples: Array[Vector2] = []
	var notes = [440.0, 370.0, 311.0, 220.0]
	for note in notes:
		for i in range(5513):
			var t = float(i) / 44100.0
			var env = max(0.0, 1.0 - t / 0.125)
			samples.append(Vector2(
				sin(TAU * note * t) * env * 0.4,
				sin(TAU * note * t * 1.5) * env * 0.12
			))
	_start_playback(samples)

func _start_playback(samples: Array[Vector2]) -> void:
	stop()
	_pending_samples = samples
	var gen = AudioStreamGenerator.new()
	gen.mix_rate = 44100.0
	gen.buffer_length = 0.1
	stream = gen
	play()
