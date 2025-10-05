extends Node

var sounds: Dictionary = {}

var operator: AudioStreamPlayer

func _ready():
	operator = AudioStreamPlayer.new()
	add_child(operator)
	
	sounds["walk"] = load("res://ART/Sounds/step.wav")
	sounds["portail"] = load("res://ART/Sounds/transport.wav")
	
func play_sound(name: String, pitch_randomize := true):
	if not sounds.has(name):
		push_warning("song unknown : "+ name)
		return
		
	operator.stream = sounds[name]
	if pitch_randomize:
		operator.pitch_scale = randf_range(0.9,1.1)
	else:
		operator.pitch_scale = 1.0
	operator.play()
