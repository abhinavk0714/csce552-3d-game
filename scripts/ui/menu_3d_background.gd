extends Node3D

# Script to animate the Aro model in the main menu background
# Plays victory dance animation

var animation_player: AnimationPlayer

func _ready():
	# Use call_deferred to ensure nodes are fully loaded
	call_deferred("_setup_animation")

func _setup_animation():
	# Find the AroModel node
	var aro_model = get_node_or_null("AroRotator/AroModel")
	if not aro_model:
		aro_model = get_node_or_null("AroModel")
	if not aro_model:
		aro_model = _find_aro_recursive(self)
	
	if not aro_model:
		push_warning("Menu3D: Aro model not found")
		return
	
	# Find AnimationPlayer in the Aro model
	animation_player = _find_animation_player(aro_model)
	if animation_player:
		# Set Victory animation to ping-pong (plays forward then backward)
		if "Victory" in animation_player.get_animation_list():
			var victory_anim = animation_player.get_animation("Victory")
			if victory_anim:
				victory_anim.loop_mode = Animation.LOOP_PINGPONG
			# Play the victory animation
			animation_player.play("Victory")
		else:
			push_warning("Menu3D: Victory animation not found. Available: %s" % animation_player.get_animation_list())
	else:
		push_warning("Menu3D: AnimationPlayer not found in Aro model")

func _find_aro_recursive(node: Node) -> Node3D:
	if node.name.contains("Aro") or node.name.contains("frog"):
		return node as Node3D
	for child in node.get_children():
		var result = _find_aro_recursive(child)
		if result:
			return result
	return null

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var result = _find_animation_player(child)
		if result:
			return result
	return null

