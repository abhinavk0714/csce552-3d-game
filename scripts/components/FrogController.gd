extends Node3D

@export var animation_speed_multiplier: float = 3.0
@export var walking_animation_name: String = "Walk"
@export var flip_animation_name: String = "Flip"
@export var dance_animation_name: String = "Victory"  # Dance animation (Victory from the sliced animations)
@export var flip_animation_speed: float = 1.5  # Faster speed for flip animation

var parent_rigidbody: RigidBody3D
var animation_player: AnimationPlayer
var is_playing_special_animation: bool = false  # Track if flip or dance is playing
var spring_cooldown: float = 0.0  # Prevent multiple spring triggers
var last_spring_trigger_time: float = 0.0
var last_coin_trigger_time: float = 0.0
var coin_cooldown: float = 0.0  # No cooldown - instant
var was_moving: bool = false  # Track previous movement state

func _ready():
	var gimbal = get_parent()
	if gimbal:
		parent_rigidbody = gimbal.get_node_or_null("../Ball") as RigidBody3D
	
	if not parent_rigidbody:
		push_error("FrogController: Could not find parent RigidBody3D (Ball)")
		return
	
	# Prioritize Aro-frog-2 (new model with sliced animations)
	var frog_node = get_node_or_null("Aro-frog-2")
	if not frog_node:
		frog_node = get_node_or_null("Aro-frog-1")
	
	if frog_node:
		animation_player = frog_node.get_node_or_null("AnimationPlayer")
		if animation_player:
			# Set loop modes once at startup - don't change them every frame
			# Use call_deferred to ensure animations are fully loaded
			call_deferred("_setup_animation_loops")
		else:
			push_warning("FrogController: Could not find AnimationPlayer in frog node")
	else:
		push_warning("FrogController: Could not find Aro-frog-2 or Aro-frog-1 node")
	
	scale = Vector3(0.6, 0.6, 0.6)  # Slightly bigger than before (was 0.5)
	
	# Connect to all springs, buttons, and coins in the scene
	call_deferred("_connect_to_interactables")

func _setup_animation_loops():
	if not animation_player:
		return
	
	# Set loop modes once - don't change them every frame
	# Use PINGPONG for smooth looping (plays forward then backward)
	if walking_animation_name in animation_player.get_animation_list():
		var walk_anim = animation_player.get_animation(walking_animation_name)
		if walk_anim:
			walk_anim.loop_mode = Animation.LOOP_PINGPONG  # Ping-pong for smooth looping
	
	# Set flip and dance to not loop
	if flip_animation_name in animation_player.get_animation_list():
		var flip_anim = animation_player.get_animation(flip_animation_name)
		if flip_anim:
			flip_anim.loop_mode = Animation.LOOP_NONE
	
	if dance_animation_name in animation_player.get_animation_list():
		var dance_anim = animation_player.get_animation(dance_animation_name)
		if dance_anim:
			dance_anim.loop_mode = Animation.LOOP_NONE
	
	# Connect to GameManager's bug_collected signal for dance animation
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager and game_manager.has_signal("bug_collected"):
		game_manager.bug_collected.connect(_on_coin_collected)
	
	# Set initial rotation to face forward
	# In Godot, -Z is forward, so atan2(0, -(-1)) = atan2(0, 1) = 0
	# But we want to face the direction the ball will move, which is typically -Z
	rotation.y = 0.0  # Face forward (-Z direction)

func _connect_to_interactables():
	var scene_root = get_tree().current_scene
	if not scene_root:
		return
	
	# Find all springs in the scene
	var springs = _find_all_springs(scene_root)
	for spring in springs:
		if spring.has_signal("spring_activated"):
			# Disconnect first to prevent duplicates
			if spring.spring_activated.is_connected(_on_spring_activated):
				spring.spring_activated.disconnect(_on_spring_activated)
			spring.spring_activated.connect(_on_spring_activated)
	
	# Find all buttons in the scene
	var buttons = _find_all_buttons(scene_root)
	for button in buttons:
		# Connect to ButtonInteraction's button_pressed signal
		var button_interaction = button.get_node_or_null("Area3D")
		if button_interaction and button_interaction.has_signal("button_pressed"):
			button_interaction.button_pressed.connect(_on_button_pressed)

func _find_all_springs(node: Node) -> Array:
	var springs = []
	if node.get_script():
		var script_path = node.get_script().resource_path
		if script_path and "SpringBehavior" in script_path:
			springs.append(node)
	
	for child in node.get_children():
		springs.append_array(_find_all_springs(child))
	
	return springs

func _find_all_buttons(node: Node) -> Array:
	var buttons = []
	if node.get_script():
		var script_path = node.get_script().resource_path
		if script_path and "button.gd" in script_path:
			buttons.append(node)
	
	for child in node.get_children():
		buttons.append_array(_find_all_buttons(child))
	
	return buttons

func _on_spring_activated(body: RigidBody3D):
	# Only play flip if it's actually the ball that hit the spring
	if body != parent_rigidbody or body.name != "Ball":
		return
	
	# Additional cooldown check to prevent spam
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_spring_trigger_time < 0.5:  # 0.5 second cooldown
		return
	
	# Don't play if already playing a special animation
	if is_playing_special_animation:
		return
	
	last_spring_trigger_time = current_time
	play_flip_animation()

func _on_button_pressed():
	# Buttons no longer trigger dance - coins do
	pass

func _on_coin_collected():
	# Play dance animation instantly when a coin is collected
	# Don't play if already playing a special animation
	if is_playing_special_animation:
		return
	
	play_dance_animation()

func _physics_process(delta):
	if not parent_rigidbody:
		return
	
	_update_facing_rotation(delta)
	_update_animation()

func _update_facing_rotation(delta):
	var velocity = parent_rigidbody.linear_velocity
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	var rotation_speed = 8.0
	
	if horizontal_velocity.length() > 0.1:
		# Calculate the direction the ball is moving
		var target_direction = horizontal_velocity.normalized()
		# Try different rotation offsets to find the correct facing
		# Start with adding PI/2 (90 degrees) offset
		var target_rotation_y = atan2(target_direction.x, -target_direction.z) + PI / 2.0
		var current_y = rotation.y
		# Smoothly rotate to face the movement direction
		rotation.y = lerp_angle(current_y, target_rotation_y, rotation_speed * delta)

func _update_animation():
	if not animation_player:
		return
	
	# Don't update walking animation if special animations (flip or dance) are playing
	if is_playing_special_animation:
		return
	
	var velocity = parent_rigidbody.linear_velocity
	var speed = velocity.length()
	var is_moving = speed > 0.1
	
	# Only change animation state when movement state actually changes
	# This prevents constant restarting that causes glitching
	if is_moving and not was_moving:
		# Started moving - start walk animation
		if walking_animation_name != "" and walking_animation_name in animation_player.get_animation_list():
			if animation_player.is_playing():
				animation_player.stop()
			animation_player.play(walking_animation_name)
	elif not is_moving and was_moving:
		# Stopped moving - stop walk animation
		if animation_player.is_playing() and animation_player.current_animation == walking_animation_name:
			animation_player.stop()
	
	was_moving = is_moving

func play_flip_animation():
	if not animation_player or is_playing_special_animation:
		return  # Don't interrupt if already playing special animation
		
	if flip_animation_name != "" and flip_animation_name in animation_player.get_animation_list():
		# Stop current animation if playing
		if animation_player.is_playing():
			animation_player.stop()
		
		is_playing_special_animation = true
		# Set speed for flip animation
		animation_player.speed_scale = flip_animation_speed
		
		# Play flip animation (loop mode already set in _ready)
		animation_player.play(flip_animation_name)
		# Connect to animation finished signal to resume walking (only once)
		if not animation_player.animation_finished.is_connected(_on_special_animation_finished):
			animation_player.animation_finished.connect(_on_special_animation_finished)

func play_dance_animation():
	if not animation_player or is_playing_special_animation:
		return  # Don't interrupt if already playing special animation
		
	if dance_animation_name != "" and dance_animation_name in animation_player.get_animation_list():
		# Stop current animation if playing
		if animation_player.is_playing():
			animation_player.stop()
		
		is_playing_special_animation = true
		# Reset speed scale for dance
		animation_player.speed_scale = 1.0
		
		# Play dance animation (loop mode already set in _ready)
		animation_player.play(dance_animation_name)
		# Connect to animation finished signal to resume walking (only once)
		if not animation_player.animation_finished.is_connected(_on_special_animation_finished):
			animation_player.animation_finished.connect(_on_special_animation_finished)

func _on_special_animation_finished(anim_name: StringName):
	if anim_name == flip_animation_name or anim_name == dance_animation_name:
		# Reset speed scale and allow walking animation to resume
		animation_player.speed_scale = 1.0
		is_playing_special_animation = false
		
		# Immediately check if we should resume walking
		var velocity = parent_rigidbody.linear_velocity
		var speed = velocity.length()
		if speed > 0.1 and walking_animation_name != "":
			# Resume walking animation (loop mode already set in _ready)
			if walking_animation_name in animation_player.get_animation_list():
				animation_player.play(walking_animation_name)
