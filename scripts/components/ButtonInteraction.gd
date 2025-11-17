extends Area3D

# ButtonInteraction component
# Detects ball overlap with buttons
# Sends signals to linked components (BarrierToggle, Goal activation)

signal button_pressed
signal button_released

var is_pressed: bool = false
var overlapping_bodies: Array = []

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	monitoring = true
	monitorable = true

func _on_body_entered(body):
	if body is RigidBody3D:
		if body not in overlapping_bodies:
			overlapping_bodies.append(body)
		
		if not is_pressed:
			is_pressed = true
			# Play button press sound
			var audio_manager = get_node("/root/AudioManager")
			if audio_manager:
				var button_sound = load("res://assets/audio/sfx/button_push.wav")
				if button_sound:
					audio_manager.play_sfx(button_sound, global_position)
			button_pressed.emit()

func _on_body_exited(body):
	if body in overlapping_bodies:
		overlapping_bodies.erase(body)
	
	if overlapping_bodies.is_empty() and is_pressed:
		is_pressed = false
		button_released.emit()
