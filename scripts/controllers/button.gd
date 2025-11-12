extends AnimatableBody3D

@export var pressed: bool = false # Unpressed -> Pressed (one way)

signal button_pressed
signal button_released

var button_interaction: Area3D

func _ready():
	button_interaction = $Area3D
	
	if not button_interaction.get_script():
		var script = load("res://scripts/components/ButtonInteraction.gd")
		if script:
			button_interaction.set_script(script)
	
	if button_interaction.has_signal("button_pressed"):
		button_interaction.button_pressed.connect(_on_button_pressed)
	if button_interaction.has_signal("button_released"):
		button_interaction.button_released.connect(_on_button_released)

func _on_button_pressed():
	pressed = true
	button_pressed.emit()
	print("Button pressed!")

func _on_button_released():
	button_released.emit()
	print("Button released!")
