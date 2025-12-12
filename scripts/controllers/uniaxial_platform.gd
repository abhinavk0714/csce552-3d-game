extends AnimatableBody3D

@export var min_angle: float = -30.0
@export var max_angle: float = 30.0
@export var rotation_speed: float = 120.0

var start_transform: Transform3D

func _ready():
	# Store the starting transform
	start_transform = global_transform

func _physics_process(delta):
	var input_dir = 0.0
	if Input.is_action_pressed("ui_left"):
		input_dir += 1.0
	if Input.is_action_pressed("ui_right"):
		input_dir -= 1.0

	if input_dir != 0.0:
		var new_rotation = rotation_degrees.z + rotation_speed * input_dir * delta
		rotation_degrees.z = clamp(new_rotation, min_angle, max_angle)
	
	# Reset Logic:
	if Input.is_action_just_pressed("ui_reset"):
		restart()
		
func restart():
	global_transform = start_transform
