extends Node3D

@onready var camera: Camera3D = $Camera3D
@export var follow_offset: Vector3 = Vector3(0, 6, 12)

func _process(delta):
	# Keep camera positioned relative to the pivot
	camera.global_position = global_position + follow_offset
	camera.look_at(global_position, Vector3.UP)
