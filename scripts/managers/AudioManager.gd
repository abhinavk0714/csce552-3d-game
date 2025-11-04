extends Node

# AudioManager
# Centralizes audio playback, volume control, and audio pooling for SFX and music
# Makes it easier to play sounds without scattering AudioSource nodes

@export var master_volume: float = 1.0
@export var sfx_volume: float = 1.0
@export var music_volume: float = 1.0

var music_player: AudioStreamPlayer
var sfx_pool: Array[AudioStreamPlayer3D] = []

func _ready():
	pass

func play_sfx(sound: AudioStream, position: Vector3 = Vector3.ZERO):
	pass

func play_music(track: AudioStream):
	pass

func stop_music():
	pass

func set_master_volume(volume: float):
	pass

func set_sfx_volume(volume: float):
	pass

func set_music_volume(volume: float):
	pass
