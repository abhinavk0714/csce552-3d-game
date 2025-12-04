extends RigidBody3D

var start_transform: Transform3D

func _ready():
	# Store the starting transform
	start_transform = global_transform
	# Find DeathBarrier in the scene (it should be a sibling of the Ball)
	var death_barrier = get_node_or_null("../DeathBarrier")
	if death_barrier and death_barrier.has_signal("body_collided"):
		death_barrier.body_collided.connect(restart)

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
