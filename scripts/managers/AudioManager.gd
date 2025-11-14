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
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.volume_db = linear_to_db(music_volume * master_volume)
	music_player.finished.connect(_on_music_finished)

func play_sfx(sound: AudioStream, position: Vector3 = Vector3.ZERO):
	# TODO: Implement SFX pooling system
	pass

func play_music(track: AudioStream):
	if music_player:
		if music_player.stream == track and music_player.playing:
			return
		
		if track is AudioStreamMP3:
			track.loop = true
		elif track is AudioStreamOggVorbis:
			track.loop = true
		
		music_player.stream = track
		music_player.play()

func stop_music():
	if music_player:
		music_player.stop()

func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	if music_player:
		music_player.volume_db = linear_to_db(music_volume * master_volume)

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	if music_player:
		music_player.volume_db = linear_to_db(music_volume * master_volume)

func _on_music_finished():
	# Backup loop in case stream loop doesn't work
	if music_player and music_player.stream:
		music_player.play()
