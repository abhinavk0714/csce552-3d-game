extends AnimatableBody3D

@export var pressed: bool = 0 # Unpressed -> Pressed (one way)

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is RigidBody3D:
		pressed = 1
		print(pressed)
