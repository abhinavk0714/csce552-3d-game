extends Node3D

@onready var camera: Camera3D = $Camera3D
@export var follow_offset: Vector3 = Vector3(0, 6, 12)
@export var follow_smoothness: float = 10.0

var ball: RigidBody3D

func _ready():
	# Find the Ball node (sibling in the level)
	ball = get_node_or_null("../Ball") as RigidBody3D
	if not ball:
		# Try alternative path
		ball = get_tree().get_first_node_in_group("player") as RigidBody3D
	if not ball:
		push_error("Gimbal: Could not find Ball node")

func _physics_process(delta):
	if not ball:
		return
	
	# Directly match ball position - no lerp to prevent phasing
	global_position = ball.global_position
	global_rotation = Vector3.ZERO  # Always upright, don't rotate with ball
	
	# Position camera relative to gimbal
	camera.global_position = global_position + follow_offset
	camera.look_at(global_position, Vector3.UP)
