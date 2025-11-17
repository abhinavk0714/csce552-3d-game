extends AnimatableBody3D

# SpringBehavior component
# Applies directional impulse to player ball when contact is detected
# Can be angled to control launch direction and force

@export var launch_force: float = 10.0 # This is wonky -> feel free to play around with the exact value

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is RigidBody3D:
		body.apply_central_impulse(Vector3.UP * launch_force)
		
		# Play spring sound at reduced volume
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager:
			var spring_sound = load("res://assets/audio/sfx/spring.wav")
			if spring_sound:
				audio_manager.play_sfx(spring_sound, global_position, 0.3)  # 30% volume
