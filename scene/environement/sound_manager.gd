extends Node

var sounds: Dictionary = {}

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music" # Optionnel si tu as un bus
	add_child(music_player)

	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX" # Optionnel
	add_child(sfx_player)

	sounds["walk"] = load("res://ART/Sounds/sfx/step.wav")
	sounds["portail"] = load("res://ART/Sounds/sfx/transport.wav")
	sounds["titleMusic"] = load("res://ART/Sounds/backgroud/musique_jeu_2_(simple).ogg")
	sounds["backgroundMusic"] = load("res://ART/Sounds/backgroud/musique_jeux_1.ogg")

func play_sfx(name: String, pitch_randomize := true):
	if not sounds.has(name):
		push_warning("sound unknown: " + name)
		return

	sfx_player.stream = sounds[name]
	if pitch_randomize:
		sfx_player.pitch_scale = randf_range(0.9, 1.1)
	else:
		sfx_player.pitch_scale = 1.0
	sfx_player.play()

func play_music(name: String):
	if not sounds.has(name):
		push_warning("music unknown: " + name)
		return

	music_player.stream = sounds[name]
	
	#if music_player.stream is AudioStreamOggVorbis:
		#music_player.stream.loop = loop
	#elif music_player.stream is AudioStreamSample:
		#music_player.stream.loop_mode = AudioStreamSample.LOOP_FORWARD
		
	music_player.play()
