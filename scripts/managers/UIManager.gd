extends CanvasLayer

# UIManager
# Manages HUD updates, menu toggles (pause/resume), and screen messages
# Bridges GameManager <-> Canvas UI elements
# Handles localization hooks and UI transitions if needed

@export var hud: Control
@export var pause_menu: Control
@export var main_menu: Control

func _ready():
	pass

func update_hud():
	pass

func update_timer(time: float):
	pass

func update_bugs(collected: int, total: int):
	pass

func show_pause_menu():
	pass

func hide_pause_menu():
	pass

func show_message(text: String):
	pass

func hide_message():
	pass
