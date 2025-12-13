extends Node3D

# Script to animate the Aro model in the main menu background
# Makes Aro rotate slowly for a nice visual effect

@export var rotation_speed: float = 0.3  # Degrees per second
var aro_model: Node3D

func _ready():
	# Find the Aro model (it might be nested in the GLB scene)
	aro_model = get_node_or_null("AroModel")
	if not aro_model:
		# Try to find it recursively
		aro_model = _find_aro_recursive(self)

func _find_aro_recursive(node: Node) -> Node3D:
	if node.name.contains("Aro") or node.name.contains("frog"):
		return node as Node3D
	for child in node.get_children():
		var result = _find_aro_recursive(child)
		if result:
			return result
	return null

func _process(delta):
	if aro_model:
		# Rotate around Y axis (vertical)
		aro_model.rotate_y(deg_to_rad(rotation_speed * delta))

