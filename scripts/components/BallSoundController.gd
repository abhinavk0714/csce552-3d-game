extends RigidBody3D

# BallSoundController component
# Handles rolling sound and collision sounds for the ball
# Volume of roll sound is based on velocity

@export var roll_sound: AudioStream
@export var quiet_plonk_sound: AudioStream
@export var loud_plonk_sound: AudioStream
@export var min_roll_velocity: float = 0.5  # Minimum velocity to play roll sound
@export var max_roll_velocity: float = 10.0  # Velocity at which roll is at max volume
@export var plonk_velocity_threshold: float = 3.0  # Velocity threshold for loud vs quiet plonk
@export var min_landing_velocity: float = 2.0  # Minimum downward velocity to trigger landing sound
@export var plonk_volume: float = 0.15  # Volume multiplier for plonk sounds (reduced from 1.0)

var roll_player: AudioStreamPlayer3D
var last_collision_velocity: float = 0.0
var collision_cooldown: float = 0.0
var min_collision_cooldown: float = 0.3  # Prevent too many collision sounds
var last_velocity: Vector3 = Vector3.ZERO
var last_position: Vector3 = Vector3.ZERO

func _ready():
	# Enable contact monitoring for collision detection
	contact_monitor = true
	max_contacts_reported = 10
	
	# Create roll sound player
	roll_player = AudioStreamPlayer3D.new()
	roll_player.volume_db = -80  # Start muted
	roll_player.autoplay = false
	add_child(roll_player)
	
	# Load sounds if not set
	if not roll_sound:
		roll_sound = load("res://assets/audio/sfx/roll.wav")
		if roll_sound:
			roll_player.stream = roll_sound
			if roll_sound is AudioStreamWAV:
				roll_sound.loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	if not quiet_plonk_sound:
		quiet_plonk_sound = load("res://assets/audio/sfx/quiet_plonk.wav")
	
	if not loud_plonk_sound:
		loud_plonk_sound = load("res://assets/audio/sfx/loud_plonk.wav")
	
	# Connect collision signal
	body_shape_entered.connect(_on_body_shape_entered)

func _physics_process(delta):
	collision_cooldown = max(0.0, collision_cooldown - delta)
	
	# Handle roll sound based on velocity
	if roll_sound and roll_player:
		var velocity_magnitude = linear_velocity.length()
		
		if velocity_magnitude > min_roll_velocity:
			# Calculate volume based on velocity (0.0 to 1.0)
			var volume_factor = clamp((velocity_magnitude - min_roll_velocity) / (max_roll_velocity - min_roll_velocity), 0.0, 1.0)
			var volume_db = linear_to_db(volume_factor * 0.8)  # Max volume at 0.8 (slightly quieter)
			
			roll_player.volume_db = volume_db
			
			if not roll_player.playing:
				roll_player.play()
		else:
			# Fade out or stop if moving too slowly
			roll_player.volume_db = -80
			if roll_player.playing:
				roll_player.stop()
	
	last_velocity = linear_velocity
	last_position = global_position

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	# Handle collision sounds - only for barriers and platform landings
	if collision_cooldown > 0.0:
		return
	
	# Check if the body is a barrier or platform
	var is_barrier: bool = false
	var is_platform: bool = false
	
	if body is StaticBody3D:
		# Check if it's a barrier (has BarrierToggle script)
		if body.get_script():
			var script_path = body.get_script().resource_path
			if script_path and "BarrierToggle" in script_path:
				is_barrier = true
		
		# Check if it's a platform (has platform-related name or is StaticBody3D without BarrierToggle)
		if not is_barrier:
			var body_name = body.name.to_lower()
			if "platform" in body_name or "Platform" in body.name:
				is_platform = true
			# Also check if it's a StaticBody3D that's not a barrier (likely a platform)
			elif body is StaticBody3D:
				is_platform = true
	
	# Check for AnimatableBody3D platforms (biaxial, uniaxial platforms)
	if body is AnimatableBody3D:
		var body_name = body.name.to_lower()
		if "platform" in body_name or "Platform" in body.name:
			is_platform = true
	
	# Only play sound for barriers or platform landings
	if not is_barrier and not is_platform:
		return
	
	# For platforms, check if we're landing from a height (downward velocity)
	if is_platform:
		var downward_velocity = -last_velocity.y  # Negative Y is downward (so we negate it)
		if downward_velocity < min_landing_velocity:
			return  # Not landing fast enough (not falling fast enough)
	
	# Get velocity magnitude for sound selection
	var velocity_magnitude = last_velocity.length()
	
	if velocity_magnitude > 0.1:  # Only play sound if actually moving
		var audio_manager = get_node("/root/AudioManager")
		var sound_to_play: AudioStream = null
		
		if velocity_magnitude > plonk_velocity_threshold:
			sound_to_play = loud_plonk_sound
		else:
			sound_to_play = quiet_plonk_sound
		
		if sound_to_play and audio_manager:
			# Play with greatly reduced volume
			audio_manager.play_sfx(sound_to_play, global_position, plonk_volume)
			collision_cooldown = min_collision_cooldown

