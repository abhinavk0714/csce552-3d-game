extends Area3D

# BugCollectible component
# Handles flying bug behavior, collision detection, and HUD increment
# Destroys or deactivates after collection and triggers SFX/particles

signal bug_collected

@export var rotation_speed: float = 2.0  # Rotation speed in radians per second
@export var hover_amplitude: float = 0.5  # Vertical hover movement amplitude
@export var hover_speed: float = 2.0  # Hover oscillation speed

var is_collected: bool = false
var initial_y: float = 0.0
var time_elapsed: float = 0.0

func _ready():
	body_entered.connect(_on_body_entered)
	initial_y = global_position.y
	monitoring = true
	monitorable = true

func _process(delta):
	if is_collected:
		return
	
	time_elapsed += delta
	rotate_y(rotation_speed * delta)
	
	var hover_offset = sin(time_elapsed * hover_speed) * hover_amplitude
	global_position.y = initial_y + hover_offset

func _on_body_entered(body):
	if is_collected:
		return
	
	# Check if the body is the player (RigidBody3D)
	if body is RigidBody3D:
		collect()

func collect():
	if is_collected:
		return
	
	is_collected = true
	bug_collected.emit()
	get_node("/root/GameManager").collect_bug()
	
	# Play coin collect sound
	var audio_manager = get_node("/root/AudioManager")
	if audio_manager:
		var coin_sound = load("res://assets/audio/sfx/coin_collect.wav")
		if coin_sound:
			audio_manager.play_sfx(coin_sound, global_position)
	
	monitoring = false
	monitorable = false
	visible = false
	
	# TODO: Add particle effect
