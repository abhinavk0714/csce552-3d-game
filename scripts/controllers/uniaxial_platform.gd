extends AnimatableBody3D

@export var min_angle: float = -30.0
@export var max_angle: float = 30.0
@export var rotation_speed: float = 60.0

func _process(delta):
	var input_dir = 0.0
	if Input.is_action_pressed("ui_left"):
		input_dir += 1.0
	if Input.is_action_pressed("ui_right"):
		input_dir -= 1.0

	if input_dir != 0.0:
		var new_rotation = rotation_degrees.z + rotation_speed * input_dir * delta
		rotation_degrees.z = clamp(new_rotation, min_angle, max_angle)
