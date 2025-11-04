extends AnimatableBody3D

@export var launch_force: float = 10.0 # This is wonky -> feel free to play around with the exact value

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is RigidBody3D:
		body.apply_central_impulse(Vector3.UP * launch_force)
