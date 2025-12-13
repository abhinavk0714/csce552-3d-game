extends AnimatableBody3D

@export var pressed: bool = 0 # Unpressed -> Pressed (one way)
@export var animation_name: String = ""
@export var animation_speed: float = 3.0  # Speed multiplier for button animation (higher = faster)

var animation_player: AnimationPlayer
var has_played_animation: bool = false

func _ready():
	$Area3D.body_entered.connect(_on_body_entered)
	
	# Try to find AnimationPlayer in ButtonModel (similar to SpringBehavior)
	call_deferred("_find_button_animation_player")

func _find_button_animation_player():
	# First try ButtonModel node
	var button_model = get_node_or_null("ButtonModel")
	if button_model:
		animation_player = button_model.get_node_or_null("AnimationPlayer")
		if animation_player:
			print("Button: Found AnimationPlayer in ButtonModel")
			return
	
	# Try to find it recursively in ButtonModel
	if button_model:
		animation_player = _find_animation_player(button_model)
		if animation_player:
			print("Button: Found AnimationPlayer recursively in ButtonModel")
			return
	
	# Try to find it anywhere in the Button node
	animation_player = _find_animation_player(self)
	if animation_player:
		print("Button: Found AnimationPlayer in Button node")
		return
	
	# If still not found, try direct child
	animation_player = get_node_or_null("AnimationPlayer")
	if animation_player:
		print("Button: Found AnimationPlayer as direct child")
		return
	
	push_warning("Button: Could not find AnimationPlayer. Button animation will not play.")

func _find_animation_player(node: Node) -> AnimationPlayer:
	for child in node.get_children():
		if child is AnimationPlayer:
			return child
		var found = _find_animation_player(child)
		if found:
			return found
	return null

func _on_body_entered(body):
	if body is RigidBody3D and not pressed:
		pressed = 1
		print(pressed)
		
		# Play button animation if available and not already played
		if animation_player:
			# Set animation speed before playing
			animation_player.speed_scale = animation_speed
			
			if animation_name != "" and not has_played_animation:
				var available_animations = animation_player.get_animation_list()
				if animation_name in available_animations:
					animation_player.play(animation_name)
					has_played_animation = true
					print("Button: Playing animation '%s' at speed %.2f" % [animation_name, animation_speed])
				else:
					push_warning("Button: Animation '%s' not found. Available: %s" % [animation_name, available_animations])
			elif animation_name == "" and not has_played_animation:
				# If no animation name specified, try to play the first available animation
				var available_animations = animation_player.get_animation_list()
				if available_animations.size() > 0:
					animation_player.play(available_animations[0])
					has_played_animation = true
					print("Button: Playing first available animation '%s' at speed %.2f" % [available_animations[0], animation_speed])
		else:
			push_warning("Button: No AnimationPlayer found for button animation")
