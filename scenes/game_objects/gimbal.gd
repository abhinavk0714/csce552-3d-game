extends Node3D

@onready var camera: Camera3D = $Camera3D
@export var follow_offset: Vector3 = Vector3(0, 6, 12)

var ball: RigidBody3D

func _ready():
	# Get the parent Ball (RigidBody3D)
	ball = get_parent() as RigidBody3D
	if not ball:
		push_error("Gimbal: Parent must be a RigidBody3D (Ball)")

func _process(delta):
	if not ball:
		return
	
	# Follow the ball's position but don't inherit its rotation
	# Set global position to ball's position, but keep rotation at identity
	global_position = ball.global_position
	global_rotation = Vector3.ZERO  # No rotation - always upright
	
	# Keep camera positioned relative to the pivot
	camera.global_position = global_position + follow_offset
	camera.look_at(global_position, Vector3.UP)
