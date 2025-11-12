extends RigidBody3D

var start_transform: Transform3D

func _ready():
	# Store the starting transform
	start_transform = global_transform

func _process(delta):
	if Input.is_action_just_pressed("ui_reset"):
		warp_to_start()

func warp_to_start():
	# Safely teleport the rigidbody back
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = true             # temporarily freeze physics simulation
	global_transform = start_transform
	freeze = false
