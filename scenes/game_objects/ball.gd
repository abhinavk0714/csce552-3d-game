extends RigidBody3D

var start_transform: Transform3D

func _ready():
	# Store the starting transform
	start_transform = global_transform
	get_node("/root/test_world/DeathBarrier").body_collided.connect(restart)

func _process(delta):
	if Input.is_action_just_pressed("ui_reset"):
		restart()

func restart():
	# Safely teleport the rigidbody back
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = true
	global_transform = start_transform
	freeze = false
