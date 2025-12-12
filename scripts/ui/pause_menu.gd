extends Control

# PauseMenu script
# Handles pause menu UI and pause/unpause functionality

var resume_button: Button
var settings_button: Button
var main_menu_button: Button
var settings_popup: Panel

func _ready():
	# Set process mode to always so input works when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Also set CanvasLayer to always process
	var canvas_layer = get_node_or_null("CanvasLayer")
	if canvas_layer:
		canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	
	resume_button = get_node_or_null("CanvasLayer/MenuPanel/VBoxContainer/ResumeButton")
	settings_button = get_node_or_null("CanvasLayer/MenuPanel/VBoxContainer/SettingsButton")
	main_menu_button = get_node_or_null("CanvasLayer/MenuPanel/VBoxContainer/MainMenuButton")
	settings_popup = get_node_or_null("CanvasLayer/SettingsPopup")
	
	if resume_button:
		resume_button.pressed.connect(_on_resume_button_pressed)
		resume_button.process_mode = Node.PROCESS_MODE_ALWAYS
	if settings_button:
		settings_button.pressed.connect(_on_settings_button_pressed)
		settings_button.process_mode = Node.PROCESS_MODE_ALWAYS
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_button_pressed)
		main_menu_button.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Set settings popup to always process
	if settings_popup:
		settings_popup.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Ensure game is not paused when level loads - call after tree is ready
	call_deferred("_ensure_unpaused")

func _ensure_unpaused():
	# Force unpause and hide menu
	get_tree().paused = false
	visible = false
	# Also hide the background and panel explicitly
	var background = get_node_or_null("Background")
	if background:
		background.visible = false
	var menu_panel = get_node_or_null("CanvasLayer/MenuPanel")
	if menu_panel:
		menu_panel.visible = false

func _input(event):
	# Handle P key to pause/unpause (only when not in main menu)
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause():
	if visible:
		unpause()
	else:
		pause()

func pause():
	get_tree().paused = true
	visible = true
	# Show background and panel
	var background = get_node_or_null("Background")
	if background:
		background.visible = true
	var menu_panel = get_node_or_null("CanvasLayer/MenuPanel")
	if menu_panel:
		menu_panel.visible = true
	_play_ui_click()

func unpause():
	get_tree().paused = false
	visible = false
	# Hide background and panel
	var background = get_node_or_null("Background")
	if background:
		background.visible = false
	var menu_panel = get_node_or_null("CanvasLayer/MenuPanel")
	if menu_panel:
		menu_panel.visible = false
	_play_ui_click()

func _play_ui_click():
	var audio_manager = get_node_or_null("/root/AudioManager")
	if audio_manager:
		audio_manager.play_ui_click()

func _on_resume_button_pressed():
	_play_ui_click()
	unpause()

func _on_settings_button_pressed():
	_play_ui_click()
	if settings_popup:
		settings_popup.show_popup()

func _on_main_menu_button_pressed():
	_play_ui_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

