extends Node

var music: AudioStreamPlayer
var skate: AudioStreamPlayer
var effects: Array[AudioStreamPlayer] = []
var cursor := 0
var enabled := true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	enabled = DisplayServer.get_name() != "headless"
	for name in ["Music", "Effects"]:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, name)
	music = AudioStreamPlayer.new()
	music.stream = load("res://assets/audio/festival.wav")
	music.bus = "Music"
	add_child(music)
	music.finished.connect(func(): music.play())
	if enabled: music.play()
	for i in range(12):
		var effect := AudioStreamPlayer.new()
		effect.bus = "Effects"
		add_child(effect)
		effects.append(effect)
	skate = AudioStreamPlayer.new()
	skate.stream = load("res://assets/audio/skate.wav")
	skate.bus = "Effects"
	add_child(skate)
	skate.finished.connect(func(): skate.play())
	skate.volume_db = -80
	if enabled: skate.play()
	volume("Music", float(Save.data["music"]))
	volume("Effects", float(Save.data["sfx"]))

func volume(bus: String, value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear_to_db(maxf(value, 0.0001)))
	AudioServer.set_bus_mute(AudioServer.get_bus_index(bus), value <= 0)

func sfx(name: String, pitch := 1.0) -> void:
	if not enabled: return
	var effect := effects[cursor % effects.size()]
	cursor += 1
	effect.stream = load("res://assets/audio/" + name + ".wav")
	effect.pitch_scale = pitch
	effect.play()

func shutdown() -> void:
	music.stop()
	music.stream = null
	skate.stop()
	skate.stream = null
	for effect in effects:
		effect.stop()
		effect.stream = null

func _exit_tree() -> void:
	shutdown()
