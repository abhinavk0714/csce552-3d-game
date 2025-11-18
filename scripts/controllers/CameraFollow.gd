extends Camera3D

# CameraFollow component
# Smoothly pans/zooms camera to follow ball and keep playfield readable
# Handles clamping, smoothing, and isometric offset to maintain visibility

@export var target: Node3D
@export var follow_speed: float = 5.0
@export var offset: Vector3 = Vector3(0, 7, 7)

func _ready():
	if not target:
		# Try to find the Ball node if target is not set
		target = get_node_or_null("../Ball")

func _process(delta):
	if target:
		update_camera_position(delta)

func update_camera_position(delta: float = 0.0):
	if not target:
		return
	
	var target_position = target.global_position + offset
	var current_position = global_position
	
	# Smoothly interpolate camera position towards target
	var new_position = current_position.lerp(target_position, follow_speed * delta)
	global_position = new_position
	
	# Keep the camera looking at the target (optional - maintains isometric view)
	look_at(target.global_position, Vector3.UP)
