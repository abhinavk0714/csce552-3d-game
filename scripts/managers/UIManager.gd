extends CanvasLayer

# UIManager
# Manages HUD updates, menu toggles (pause/resume), and screen messages
# Bridges GameManager <-> Canvas UI elements
# Handles localization hooks and UI transitions if needed

@export var hud: Control
@export var pause_menu: Control
@export var main_menu: Control

var timer_label: Label
var coins_label: Label
var level_label: Label
var pause_button: Button

func _ready():
	# Find HUD in current scene
	var current_scene = get_tree().current_scene
	if current_scene:
		var hud_node = current_scene.get_node_or_null("HUD")
		if hud_node:
			timer_label = hud_node.get_node_or_null("InfoPanel/VBoxContainer/TimerLabel")
			coins_label = hud_node.get_node_or_null("InfoPanel/VBoxContainer/CoinsLabel")
			level_label = hud_node.get_node_or_null("InfoPanel/VBoxContainer/LevelLabel")
			pause_button = hud_node.get_node_or_null("PauseButton")
			if pause_button:
				pause_button.pressed.connect(_on_pause_button_pressed)
	
	# Also check if hud export is set (for backwards compatibility)
	if hud:
		timer_label = hud.get_node_or_null("InfoPanel/VBoxContainer/TimerLabel")
		coins_label = hud.get_node_or_null("InfoPanel/VBoxContainer/CoinsLabel")
		level_label = hud.get_node_or_null("InfoPanel/VBoxContainer/LevelLabel")
		pause_button = hud.get_node_or_null("PauseButton")
		if pause_button:
			pause_button.pressed.connect(_on_pause_button_pressed)
	
	var game_manager = get_node("/root/GameManager")
	game_manager.bug_collected.connect(_on_bug_collected)
	game_manager.level_complete.connect(_on_level_complete)
	game_manager.level_failed.connect(_on_level_failed)
	game_manager.time_expired.connect(_on_time_expired)
	
	# Connect to scene changed to update HUD references
	get_tree().scene_changed.connect(_on_scene_changed)
	_on_scene_changed()

func _on_scene_changed():
	# Update HUD references when scene changes
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.name != "MainMenu":
		var hud_node = current_scene.get_node_or_null("HUD")
		if hud_node:
			timer_label = hud_node.get_node_or_null("InfoPanel/VBoxContainer/TimerLabel")
			coins_label = hud_node.get_node_or_null("InfoPanel/VBoxContainer/CoinsLabel")
			level_label = hud_node.get_node_or_null("InfoPanel/VBoxContainer/LevelLabel")
			pause_button = hud_node.get_node_or_null("PauseButton")
			if pause_button:
				# Disconnect if already connected, then reconnect
				if pause_button.pressed.is_connected(_on_pause_button_pressed):
					pause_button.pressed.disconnect(_on_pause_button_pressed)
				pause_button.pressed.connect(_on_pause_button_pressed)
		update_hud()

func _process(_delta):
	var game_manager = get_node("/root/GameManager")
	update_timer(game_manager.time_remaining)

func update_hud():
	var game_manager = get_node("/root/GameManager")
	update_timer(game_manager.time_remaining)
	update_coins(game_manager.bugs_collected)
	update_level(game_manager.current_level)

func update_timer(time_remaining: float):
	if timer_label:
		var minutes = int(time_remaining) / 60
		var seconds = int(time_remaining) % 60
		# Change color to red if less than 1 minute remaining
		if time_remaining < 60.0:
			timer_label.modulate = Color(1, 0.3, 0.3, 1)  # Red tint
		else:
			timer_label.modulate = Color(1, 1, 1, 1)  # White
		timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

func update_coins(collected: int):
	if coins_label:
		coins_label.text = "Coins: %d" % collected

func update_level(level: int):
	if level_label:
		level_label.text = "Level: %d" % level

func show_pause_menu():
	if pause_menu:
		pause_menu.visible = true
		get_tree().paused = true

func hide_pause_menu():
	if pause_menu:
		pause_menu.visible = false
		get_tree().paused = false

func show_message(text: String):
	# TODO: Implement message display system
	pass

func hide_message():
	# TODO: Implement message hide system
	pass

func _on_bug_collected():
	var game_manager = get_node("/root/GameManager")
	update_coins(game_manager.bugs_collected)

func _on_level_complete():
	# TODO: Show level complete message
	pass

func _on_level_failed():
	# TODO: Show game over message
	pass

func _on_time_expired():
	# Time expired - will be reset to tutorial by GameManager
	pass

func _on_pause_button_pressed():
	# Find pause menu in current scene and toggle it
	var current_scene = get_tree().current_scene
	if current_scene:
		var pause_menu = current_scene.get_node_or_null("PauseMenu")
		if pause_menu and pause_menu.has_method("toggle_pause"):
			pause_menu.toggle_pause()
		elif pause_menu:
			# Fallback: manually toggle pause
			if pause_menu.visible:
				# Unpause
				pause_menu.visible = false
				var background = pause_menu.get_node_or_null("Background")
				var menu_panel = pause_menu.get_node_or_null("CanvasLayer/MenuPanel")
				if background:
					background.visible = false
				if menu_panel:
					menu_panel.visible = false
				get_tree().paused = false
			else:
				# Pause
				pause_menu.visible = true
				var background = pause_menu.get_node_or_null("Background")
				var menu_panel = pause_menu.get_node_or_null("CanvasLayer/MenuPanel")
				if background:
					background.visible = true
				if menu_panel:
					menu_panel.visible = true
				get_tree().paused = true
