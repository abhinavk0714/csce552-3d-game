extends Node

# AudioManager
# Centralizes audio playback, volume control, and audio pooling for SFX and music
# Makes it easier to play sounds without scattering AudioSource nodes

@export var master_volume: float = 1.0
@export var sfx_volume: float = 1.0
@export var music_volume: float = 1.0

var music_player: AudioStreamPlayer
var sfx_pool: Array[AudioStreamPlayer3D] = []
var ui_sfx_pool: Array[AudioStreamPlayer] = []
var max_sfx_pool_size: int = 20
var max_ui_sfx_pool_size: int = 5

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.volume_db = linear_to_db(music_volume * master_volume)
	music_player.finished.connect(_on_music_finished)
	
	# Initialize SFX pool (3D sounds)
	for i in range(max_sfx_pool_size):
		var player = AudioStreamPlayer3D.new()
		player.volume_db = linear_to_db(sfx_volume * master_volume)
		add_child(player)
		sfx_pool.append(player)
	
	# Initialize UI SFX pool (2D sounds)
	for i in range(max_ui_sfx_pool_size):
		var player = AudioStreamPlayer.new()
		player.volume_db = linear_to_db(sfx_volume * master_volume)
		add_child(player)
		ui_sfx_pool.append(player)

func play_sfx(sound: AudioStream, position: Vector3 = Vector3.ZERO, volume: float = 1.0):
	if not sound:
		return
	
	# Find an available player from the pool
	var player: AudioStreamPlayer3D = null
	for p in sfx_pool:
		if not p.playing:
			player = p
			break
	
	# If all players are busy, use the first one (will interrupt)
	if not player:
		player = sfx_pool[0]
	
	# Configure and play
	player.stream = sound
	player.global_position = position
	player.volume_db = linear_to_db(sfx_volume * master_volume * volume)
	player.play()

func play_ui_click():
	# Play UI click sound using 2D audio player
	var ui_click_sound = load("res://assets/audio/sfx/ui_click.wav")
	if not ui_click_sound:
		return
	
	# Find an available UI player from the pool
	var player: AudioStreamPlayer = null
	for p in ui_sfx_pool:
		if not p.playing:
			player = p
			break
	
	# If all players are busy, use the first one (will interrupt)
	if not player:
		player = ui_sfx_pool[0]
	
	# Configure and play
	player.stream = ui_click_sound
	player.volume_db = linear_to_db(sfx_volume * master_volume * 1.2)  # Louder for UI to be heard over music
	player.play()

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
	# Update all SFX players in the pool (3D)
	for player in sfx_pool:
		if player:
			player.volume_db = linear_to_db(sfx_volume * master_volume)
	# Update all UI SFX players in the pool (2D)
	for player in ui_sfx_pool:
		if player:
			player.volume_db = linear_to_db(sfx_volume * master_volume)

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	if music_player:
		music_player.volume_db = linear_to_db(music_volume * master_volume)

func _on_music_finished():
	# Backup loop in case stream loop doesn't work
	if music_player and music_player.stream:
		music_player.play()
