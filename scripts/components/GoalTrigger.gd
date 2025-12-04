extends Area3D

# GoalTrigger component
# Handles completion conditions and transitions to the next level or win menu

func _ready():
	body_entered.connect(_on_body_entered)
	monitoring = true
	monitorable = true

func _on_body_entered(body):
	if body is RigidBody3D:
		print("Goal reached!")
		var game_manager = get_node("/root/GameManager")
		if game_manager:
			game_manager.complete_level()
