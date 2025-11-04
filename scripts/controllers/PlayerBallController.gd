extends RigidBody3D

# PlayerBallController component
# Monitors ball state and translates physics feedback into Aro's animations
# Syncs rig to rolling movement
# Handles special interactions with springs and goal

@export var frog_rig: Node3D
@export var animation_player: AnimationPlayer

func _ready():
	pass

func _physics_process(delta):
	pass

func update_animations():
	pass

func handle_spring_interaction():
	pass
