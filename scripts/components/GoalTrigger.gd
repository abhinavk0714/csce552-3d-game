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
		# Show level complete popup instead of immediately loading next level
		var current_scene = get_tree().current_scene
		if current_scene:
			var popup = current_scene.get_node_or_null("LevelCompletePopup")
			if popup and popup.has_method("show_popup"):
				popup.show_popup()
			else:
				# Fallback: directly load next level if popup not found
				var game_manager = get_node("/root/GameManager")
				if game_manager:
					game_manager.complete_level()
