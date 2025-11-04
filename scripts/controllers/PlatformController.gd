extends AnimatableBody3D

# PlatformController base class
# Receives player input and applies rotation/constraints to platform transforms
# Includes max-angle limits, speed, and locked-axis logic per platform instance

@export var min_angle: float = -30.0
@export var max_angle: float = 30.0
@export var rotation_speed: float = 60.0

func _ready():
	pass

func _process(delta):
	pass

func apply_rotation(delta):
	pass
