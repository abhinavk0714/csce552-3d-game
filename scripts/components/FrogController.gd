extends Node3D

# FrogController component
# Simple controller that makes the frog sit on top of the ball and animate based on movement
# The frog is a child of the gimbal, so it automatically follows the ball

@export var animation_speed_multiplier: float = 3.0  # Speed multiplier for animations
@export var walking_animation_name: String = "walk"  # Name of walking animation (create this in Godot)
@export var backflip_animation_name: String = ""  # Will be auto-detected

var parent_rigidbody: RigidBody3D
var animation_player: AnimationPlayer
var current_animation: String = ""
var is_backflipping: bool = false
var backflip_timer: float = 0.0
var backflip_duration: float = 1.0  # How long to play backflip animation

func _ready():
	# Get the Ball (sibling of gimbal, which is parent of Frog)
	var gimbal = get_parent()
	if gimbal:
		parent_rigidbody = gimbal.get_node_or_null("../Ball") as RigidBody3D
	
	if not parent_rigidbody:
		push_error("FrogController: Could not find parent RigidBody3D (Ball)")
		return
	
	# Get the AnimationPlayer from the frog model
	var frog_node = get_node_or_null("Aro-frog-1")
	if frog_node:
		animation_player = frog_node.get_node_or_null("AnimationPlayer")
		if animation_player:
			var anim_list = animation_player.get_animation_list()
			print("Available animations: ", anim_list)
			
			# Try to find backflip animation (for spring jumps)
			for anim_name in anim_list:
				var name_lower = anim_name.to_lower()
				if "backflip" in name_lower or "flip" in name_lower:
					backflip_animation_name = anim_name
					break
			
			# Check if walking animation exists, if not, try to find it
			if walking_animation_name != "" and walking_animation_name not in anim_list:
				# Try to find walking animation
				for anim_name in anim_list:
					var name_lower = anim_name.to_lower()
					if "walk" in name_lower or "run" in name_lower:
						walking_animation_name = anim_name
						break
			
			# Set walking animation to loop
			if walking_animation_name != "" and walking_animation_name in anim_list:
				var anim = animation_player.get_animation(walking_animation_name)
				if anim:
					anim.loop_mode = Animation.LOOP_LINEAR
			
			# Set backflip animation to NOT loop (play once)
			if backflip_animation_name != "":
				var anim = animation_player.get_animation(backflip_animation_name)
				if anim:
					anim.loop_mode = Animation.LOOP_NONE
			
			# Connect to spring signals if available
			_connect_to_springs()
	
	# Scale down the frog (make it smaller)
	scale = Vector3(0.5, 0.5, 0.5)
	
	# Position frog on top of ball (simple Y offset - gimbal handles following the ball)
	# Position is already set in the scene to (0, 1.1, 0) which puts it on top
	# The gimbal now stays upright (no rotation), so the frog will stay upright too

func _physics_process(delta):
	if not parent_rigidbody:
		return
	
	# Update backflip timer
	if is_backflipping:
		backflip_timer -= delta
		if backflip_timer <= 0.0:
			is_backflipping = false
	
	# Rotate frog to face movement direction
	_update_facing_rotation(delta)
	
	# Handle animation based on ball movement
	_update_animation()

func _update_facing_rotation(delta):
	# Get the movement direction from linear velocity
	var velocity = parent_rigidbody.linear_velocity
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	# Rotation speed for smooth turning
	var rotation_speed = 5.0
	
	# Only rotate if there's significant horizontal movement
	if horizontal_velocity.length() > 0.1:
		# Calculate the direction the frog should face
		var target_direction = horizontal_velocity.normalized()
		
		# Rotate the frog to face the movement direction
		# Since level goes left-to-right (X axis), we want to face in the X direction
		var target_rotation_y = atan2(target_direction.x, -target_direction.z)
		
		# Smoothly rotate towards the target direction (only Y rotation)
		var current_y = rotation.y
		rotation.y = lerp_angle(current_y, target_rotation_y, rotation_speed * delta)
	else:
		# If not moving, keep facing right (0 degrees)
		rotation.y = lerp_angle(rotation.y, 0.0, rotation_speed * delta)

func _connect_to_springs():
	# Connect to all spring signals in the scene
	var root = get_tree().current_scene
	if root:
		_connect_to_springs_recursive(root)

func _connect_to_springs_recursive(node: Node):
	# Check if this node has SpringBehavior script (has the spring_activated signal)
	if node.get_script():
		var script = node.get_script()
		if script and script.resource_path.ends_with("SpringBehavior.gd"):
			if node.has_signal("spring_activated"):
				node.spring_activated.connect(_on_spring_activated)
	
	for child in node.get_children():
		_connect_to_springs_recursive(child)

func _on_spring_activated(body: RigidBody3D):
	# Only trigger if it's our ball
	if body == parent_rigidbody:
		trigger_backflip()

func trigger_backflip():
	# Trigger backflip animation
	if animation_player and backflip_animation_name != "":
		is_backflipping = true
		backflip_timer = backflip_duration
		animation_player.play(backflip_animation_name)

func _update_animation():
	if not animation_player:
		return
	
	# If backflipping, let the backflip animation play
	if is_backflipping and backflip_animation_name != "":
		if animation_player.current_animation != backflip_animation_name:
			animation_player.play(backflip_animation_name)
		return
	
	# Check if player is moving
	var velocity = parent_rigidbody.linear_velocity
	var speed = velocity.length()
	var is_moving = speed > 0.1
	
	if is_moving:
		# Play walking animation while moving
		if walking_animation_name != "" and walking_animation_name in animation_player.get_animation_list():
			if animation_player.current_animation != walking_animation_name:
				animation_player.play(walking_animation_name)
			
			# Scale animation speed based on ball speed
			var base_speed = 0.5  # Base walking speed
			var speed_factor = speed / 5.0  # Normalize speed (5 units/sec = 1.0x speed)
			var speed_scale = base_speed + (speed_factor * animation_speed_multiplier * 0.5)
			speed_scale = clamp(speed_scale, 0.5, 3.0)
			animation_player.speed_scale = speed_scale
		elif backflip_animation_name != "":
			# Fallback to backflip if walking animation doesn't exist
			if animation_player.current_animation != backflip_animation_name:
				animation_player.play(backflip_animation_name)
			var speed_scale = clamp(speed / 5.0 * animation_speed_multiplier, 0.5, 3.0)
			animation_player.speed_scale = speed_scale
	else:
		# Stop animation when not moving
		if animation_player.is_playing():
			animation_player.stop()
