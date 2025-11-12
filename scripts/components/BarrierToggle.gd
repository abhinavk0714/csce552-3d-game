extends StaticBody3D

# BarrierToggle component
# Listens for button signals and toggles barrier collision/visibility states
# Used to gate level progression and create dynamic puzzles

@export var is_active: bool = true
@export var linked_button: NodePath  # Path to the button that controls this barrier

var collision_shape: CollisionShape3D
var mesh_instance: MeshInstance3D

func _ready():
	collision_shape = get_node_or_null("CollisionShape3D")
	mesh_instance = get_node_or_null("MeshInstance3D")
	
	if is_active:
		activate()
	else:
		deactivate()
	
	if linked_button and not linked_button.is_empty():
		var button = get_node_or_null(linked_button)
		if button:
			var button_interaction = button.get_node_or_null("Area3D")
			if button_interaction and button_interaction.has_signal("button_pressed"):
				button_interaction.button_pressed.connect(_on_button_pressed)
				button_interaction.button_released.connect(_on_button_released)
			elif button.has_signal("button_pressed"):
				button.button_pressed.connect(_on_button_pressed)
				if button.has_signal("button_released"):
					button.button_released.connect(_on_button_released)

func _on_button_pressed():
	toggle_barrier()

func _on_button_released():
	# Uncomment if we want barriers to toggle back when button is released
	# toggle_barrier()
	pass

func toggle_barrier():
	if is_active:
		deactivate()
	else:
		activate()

func activate():
	is_active = true
	
	if collision_shape:
		collision_shape.disabled = false
		collision_shape.set_deferred("disabled", false)
	
	set_collision_layer(1)
	set_collision_mask(1)
	
	if mesh_instance:
		mesh_instance.visible = true
	
	print("Barrier activated - collision enabled")

func deactivate():
	is_active = false
	
	if collision_shape:
		collision_shape.disabled = true
		collision_shape.set_deferred("disabled", true)
	
	set_collision_layer(0)
	set_collision_mask(0)
	
	if mesh_instance:
		mesh_instance.visible = false
	
	print("Barrier deactivated - collision should be disabled")
