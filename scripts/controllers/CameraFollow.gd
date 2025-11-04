extends Camera3D

# CameraFollow component
# Smoothly pans/zooms camera to follow ball and keep playfield readable
# Handles clamping, smoothing, and isometric offset to maintain visibility

@export var target: Node3D
@export var follow_speed: float = 5.0
@export var offset: Vector3 = Vector3(0, 7, 7)

func _ready():
	pass

func _process(delta):
	pass

func update_camera_position():
	pass
