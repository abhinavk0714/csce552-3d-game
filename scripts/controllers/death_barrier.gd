extends Area3D

@export var objects_to_reset: Array[NodePath] = []

var _bodies_in_area = []

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is RigidBody3D:
		print("Body fell:", body.name)
		#trigger_resets()
		body.restart()
		#_reset_in_branch("test_world")
	
		
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
		
		
		
