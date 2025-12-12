extends Control

# LevelCompletePopup script
# Shows when player completes a level

var next_level_button: Button

func _ready():
	# Set process mode to always so it works when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var canvas_layer = get_node_or_null("CanvasLayer")
	if canvas_layer:
		canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	
	next_level_button = get_node_or_null("CanvasLayer/MenuPanel/VBoxContainer/NextLevelButton")
	if next_level_button:
		next_level_button.pressed.connect(_on_next_level_button_pressed)
		next_level_button.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Start hidden
	visible = false
	var background = get_node_or_null("Background")
	var menu_panel = get_node_or_null("CanvasLayer/MenuPanel")
	if background:
		background.visible = false
	if menu_panel:
		menu_panel.visible = false

func show_popup():
	# Pause the game
	get_tree().paused = true
	
	# Show popup
	visible = true
	var background = get_node_or_null("Background")
	var menu_panel = get_node_or_null("CanvasLayer/MenuPanel")
	if background:
		background.visible = true
	if menu_panel:
		menu_panel.visible = true
	
	_play_ui_click()

func hide_popup():
	visible = false
	var background = get_node_or_null("Background")
	var menu_panel = get_node_or_null("CanvasLayer/MenuPanel")
	if background:
		background.visible = false
	if menu_panel:
		menu_panel.visible = false

func _play_ui_click():
	var audio_manager = get_node_or_null("/root/AudioManager")
	if audio_manager:
		audio_manager.play_ui_click()

func _on_next_level_button_pressed():
	_play_ui_click()
	# Unpause and load next level
	get_tree().paused = false
	hide_popup()
	
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		game_manager.load_next_level()

