extends Area3D

@export var objects_to_reset: Array[NodePath] = []
@export var offset_below_lowest: float = 20.0  # Distance below lowest platform

var _bodies_in_area = []

func _ready():
	body_entered.connect(_on_body_entered)
	# Defer positioning to ensure all platforms are loaded
	call_deferred("_position_below_lowest_platform")

func _position_below_lowest_platform():
	# Find all platforms in the scene
	var scene_root = get_tree().current_scene
	
	if not scene_root:
		return
	
	# Find all StaticBody3D and AnimatableBody3D nodes (platforms)
	var lowest_y = _find_lowest_platform_recursive(scene_root, INF)
	
	# If we found a platform, position the death barrier below it
	if lowest_y != INF:
		var target_y = lowest_y - offset_below_lowest
		global_position.y = target_y
		print("Death barrier positioned at Y = ", target_y, " (", offset_below_lowest, " units below lowest platform at Y = ", lowest_y, ")")
	else:
		# Fallback: use default position if no platforms found
		print("Warning: No platforms found, using default death barrier position")

func _find_lowest_platform_recursive(node: Node, lowest_y_ref: float) -> float:
	var current_lowest = lowest_y_ref
	
	# Check if this node is a platform (StaticBody3D or AnimatableBody3D)
	if node is StaticBody3D or node is AnimatableBody3D:
		# Skip if it's the death barrier itself or other non-platform objects
		var node_name = node.name.to_lower()
		# Skip buttons, barriers, springs, bugs, and the death barrier itself
		if "barrier" in node_name or "button" in node_name or "spring" in node_name or "bug" in node_name or "death" in node_name:
			pass  # Skip these
		else:
			# Check if it's likely a platform by name or scene file
			var is_platform = false
			if "platform" in node_name:
				is_platform = true
			elif node.scene_file_path:
				# Check if it's an instance of a platform scene
				var scene_path = node.scene_file_path.to_lower()
				if "platform" in scene_path:
					is_platform = true
			
			if is_platform:
				# This is a platform - get its lowest Y position
				var platform_lowest = _get_node_lowest_y(node as Node3D)
				if platform_lowest < current_lowest:
					current_lowest = platform_lowest
	
	# Recursively check children
	for child in node.get_children():
		current_lowest = _find_lowest_platform_recursive(child, current_lowest)
	
	return current_lowest

func _get_node_lowest_y(node: Node3D) -> float:
	# Get the AABB (axis-aligned bounding box) of the node
	# This accounts for the collision shape and mesh
	var lowest = node.global_position.y
	
	# Try to get collision shape bounds
	var collision_shape = node.get_node_or_null("CollisionShape3D")
	if collision_shape and collision_shape.shape:
		var shape = collision_shape.shape
		if shape is BoxShape3D:
			var box_shape = shape as BoxShape3D
			# Get the local position of the collision shape
			var collision_pos = collision_shape.global_position
			# The bottom of the box is at position.y - (size.y / 2)
			var box_bottom = collision_pos.y - (box_shape.size.y / 2.0)
			if box_bottom < lowest:
				lowest = box_bottom
		elif shape is ConcavePolygonShape3D or shape is ConvexPolygonShape3D:
			# For complex shapes, use the node's position as approximation
			pass
	
	# Also check mesh bounds if available
	var mesh_instance = node.get_node_or_null("MeshInstance3D")
	if mesh_instance and mesh_instance.mesh:
		var mesh = mesh_instance.mesh
		if mesh:
			var aabb = mesh.get_aabb()
			var mesh_bottom = mesh_instance.global_position.y + aabb.position.y
			if mesh_bottom < lowest:
				lowest = mesh_bottom
	
	return lowest

func _on_body_entered(body):
	if body is RigidBody3D:
		print("Body fell:", body.name)
		Input.action_press("ui_reset")
	
		
func trigger_resets():
	for path in objects_to_reset:
		var node = get_node_or_null(path)
		if node and node.has_method("warp_to_start"):
			node.reset_state()

func _reset_in_branch(node):
	if node.has_method("restart"):
		node.restart()
	for child in node.get_children():
		_reset_in_branch(child)
		
		
		
