extends AnimatableBody3D

# SpringBehavior component
# Applies directional impulse to player ball when contact is detected
# Can be angled to control launch direction and force

signal spring_activated(body: RigidBody3D)

@export var launch_force: float = 10.0 # This is wonky -> feel free to play around with the exact value
@export var animation_name: String = ""
@export var animation_speed: float = 4.0  # Speed multiplier for spring animation (higher = faster)

var animation_player: AnimationPlayer
var bodies_in_area: Array = []  # Track bodies currently in area
var last_triggered_body: RigidBody3D = null
var trigger_cooldown: float = 0.3  # Shorter cooldown - 0.3 seconds
var last_trigger_time: float = 0.0

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)
	
	# Try to find AnimationPlayer - check multiple possible locations
	call_deferred("_find_spring_animation_player")

func _find_spring_animation_player():
	# First try SpringModel node
	var spring_model = get_node_or_null("SpringModel")
	if spring_model:
		animation_player = spring_model.get_node_or_null("AnimationPlayer")
		if animation_player:
			print("Spring: Found AnimationPlayer in SpringModel")
			return
	
	# Try to find it recursively in SpringModel
	if spring_model:
		animation_player = _find_animation_player(spring_model)
		if animation_player:
			print("Spring: Found AnimationPlayer recursively in SpringModel")
			return
	
	# Try to find it anywhere in the Spring node
	animation_player = _find_animation_player(self)
	if animation_player:
		print("Spring: Found AnimationPlayer in Spring node")
		return
	
	# If still not found, try direct child
	animation_player = get_node_or_null("AnimationPlayer")
	if animation_player:
		print("Spring: Found AnimationPlayer as direct child")
		return
	
	push_warning("Spring: Could not find AnimationPlayer. Spring animation will not play.")

func _find_animation_player(node: Node) -> AnimationPlayer:
	for child in node.get_children():
		if child is AnimationPlayer:
			return child
		var found = _find_animation_player(child)
		if found:
			return found
	return null

func _on_body_entered(body):
	if body is RigidBody3D:
		# Always apply force (don't skip due to cooldown)
		body.apply_central_impulse(Vector3.UP * launch_force)
		
		# Only emit signal and play animation if cooldown has passed (prevents spam)
		var current_time = Time.get_ticks_msec() / 1000.0
		if body != last_triggered_body or (current_time - last_trigger_time >= trigger_cooldown):
			last_trigger_time = current_time
			last_triggered_body = body
			spring_activated.emit(body)  # Emit signal for frog controller
		
		# Play spring animation if available
		if animation_player:
			# Set animation speed before playing
			animation_player.speed_scale = animation_speed
			
			if animation_name != "":
				var available_animations = animation_player.get_animation_list()
				if animation_name in available_animations:
					animation_player.play(animation_name)
					print("Spring: Playing animation '%s' at speed %.2f" % [animation_name, animation_speed])
				else:
					push_warning("Spring: Animation '%s' not found. Available: %s" % [animation_name, available_animations])
			else:
				# If no animation name specified, try to play the first available animation
				var available_animations = animation_player.get_animation_list()
				if available_animations.size() > 0:
					animation_player.play(available_animations[0])
					print("Spring: Playing first available animation '%s' at speed %.2f" % [available_animations[0], animation_speed])
		else:
			push_warning("Spring: No AnimationPlayer found for spring animation")
		
		# Play spring sound at reduced volume
		var audio_manager = get_node("/root/AudioManager")
		if audio_manager:
			var spring_sound = load("res://assets/audio/sfx/spring.wav")
			if spring_sound:
				audio_manager.play_sfx(spring_sound, global_position, 0.3)  # 30% volume

func _on_body_exited(body):
	if body is RigidBody3D:
		# Remove from tracking when body leaves
		if body in bodies_in_area:
			bodies_in_area.erase(body)
		# Reset last triggered body if this was it
		if body == last_triggered_body:
			# Don't reset immediately - allow cooldown to work
			pass
