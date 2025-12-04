extends Node3D

# FrogController component
# Makes the frog stay upright on top of the sphere with continuous backflip animation
# Counter-rotates to keep frog upright regardless of sphere rotation
# Plays backflip animation continuously while moving, later needs to be changed to diff animations when finished

@export var sphere_radius: float = 1.0
@export var frog_height_offset: float = 0.1  # Additional height above sphere surface
@export var animation_speed_multiplier: float = 3.0  # Speed multiplier for backflip animation

var parent_rigidbody: RigidBody3D
var animation_player: AnimationPlayer
var backflip_animation_name: String = ""
var is_moving: bool = false
var initial_rotation: Quaternion
var desired_y_rotation: float = 0.0  # Track desired Y rotation for facing direction

func _ready():
	# Get the parent RigidBody3D (the Ball)
	parent_rigidbody = get_parent() as RigidBody3D
	if not parent_rigidbody:
		push_error("FrogController: Parent must be a RigidBody3D")
		return
	
	# Store initial rotation to keep frog upright
	initial_rotation = transform.basis.get_rotation_quaternion()
	
	# Get the AnimationPlayer from the frog model
	var frog_node = get_node_or_null("Aro-frog-1")
	if frog_node:
		animation_player = frog_node.get_node_or_null("AnimationPlayer")
		if animation_player:
			# Find the backflip animation (try common names)
			var anim_list = animation_player.get_animation_list()
			print("Available animations: ", anim_list)
			
			# Try to find backflip animation by name
			for anim_name in anim_list:
				var name_lower = anim_name.to_lower()
				if "backflip" in name_lower or "flip" in name_lower or "jump" in name_lower:
					backflip_animation_name = anim_name
					break
			
			# If not found, use the first animation
			if backflip_animation_name == "" and anim_list.size() > 0:
				backflip_animation_name = anim_list[0]
			
			# Set animation to loop
			if backflip_animation_name != "":
				var anim = animation_player.get_animation(backflip_animation_name)
				if anim:
					anim.loop_mode = Animation.LOOP_LINEAR
	
	# Scale down the frog (make it smaller)
	scale = Vector3(0.5, 0.5, 0.5)
	
	# Position frog on top of sphere initially
	_update_position()

func _physics_process(delta):
	if not parent_rigidbody:
		return
	
	# Update position to stay on top of sphere
	_update_position()
	
	# Rotate frog to face movement direction (only Y rotation) - do this first
	_update_facing_rotation(delta)
	
	# Keep frog upright by counter-rotating against sphere rotation - do this after facing rotation
	_keep_upright()
	
	# Handle animation - play continuously while moving
	_update_animation()

func _update_position():
	# Position the frog on top of the sphere
	# The sphere is at the parent's origin, so we offset upward
	var sphere_height = sphere_radius + frog_height_offset
	position = Vector3(0, sphere_height, 0)

func _keep_upright():
	# Counter-rotate the frog to keep it upright
	# Get the sphere's rotation (from parent RigidBody3D)
	var sphere_basis = parent_rigidbody.transform.basis
	var sphere_rotation = sphere_basis.get_rotation_quaternion()
	
	# Invert the sphere's rotation to keep frog upright
	var counter_rotation = sphere_rotation.inverse()
	
	# Create upright basis with desired Y rotation for facing direction
	var upright_basis = Basis.from_euler(Vector3(0, desired_y_rotation, 0))
	
	# Apply counter-rotation to keep upright while preserving Y rotation
	transform.basis = Basis(counter_rotation) * upright_basis

func _update_facing_rotation(delta):
	# Get the movement direction from linear velocity
	var velocity = parent_rigidbody.linear_velocity
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	# Only rotate if there's significant horizontal movement
	if horizontal_velocity.length() > 0.1:
		# Calculate the direction the frog should face
		var target_direction = horizontal_velocity.normalized()
		
		# Rotate the frog to face the movement direction
		var target_rotation_y = atan2(target_direction.x, target_direction.z)
		
		# Smoothly rotate towards the target direction
		var rotation_speed = 5.0
		desired_y_rotation = lerp_angle(desired_y_rotation, target_rotation_y, rotation_speed * delta)

func _update_animation():
	if not animation_player or backflip_animation_name == "":
		return
	
	# Check if player is moving
	var velocity = parent_rigidbody.linear_velocity
	var speed = velocity.length()
	is_moving = speed > 0.1
	
	if is_moving:
		# Play animation continuously while moving
		if not animation_player.is_playing() or animation_player.current_animation != backflip_animation_name:
			animation_player.play(backflip_animation_name)
		
		# Speed up the animation significantly
		var base_speed = 1.0
		var speed_scale = base_speed * animation_speed_multiplier
		animation_player.speed_scale = speed_scale
	else:
		# Stop animation when not moving
		if animation_player.is_playing():
			animation_player.stop()
