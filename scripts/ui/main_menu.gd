extends Control

# MainMenu script
# Handles main menu UI interactions and scene transitions

var settings_popup: Panel
var how_to_play_popup: Panel
var about_popup: Panel
var level_select_popup: Panel

func _ready():
	var play_button = get_node_or_null("CanvasLayer/VBoxContainer/PlayButton")
	var how_to_play_button = get_node_or_null("CanvasLayer/VBoxContainer/HowToPlayButton")
	var options_button = get_node_or_null("CanvasLayer/VBoxContainer/OptionsButton")
	var about_button = get_node_or_null("CanvasLayer/VBoxContainer/AboutButton")
	var level_select_button = get_node_or_null("CanvasLayer/VBoxContainer/LevelSelectButton")
	var quit_button = get_node_or_null("CanvasLayer/VBoxContainer/QuitButton")
	settings_popup = get_node_or_null("CanvasLayer/SettingsPopup")
	how_to_play_popup = get_node_or_null("CanvasLayer/HowToPlayPopup")
	about_popup = get_node_or_null("CanvasLayer/AboutPopup")
	level_select_popup = get_node_or_null("CanvasLayer/LevelSelectPopup")
	
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
	if how_to_play_button:
		how_to_play_button.pressed.connect(_on_how_to_play_button_pressed)
	if options_button:
		options_button.pressed.connect(_on_options_button_pressed)
	if about_button:
		about_button.pressed.connect(_on_about_button_pressed)
	if level_select_button:
		level_select_button.pressed.connect(_on_level_select_button_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)
	
	# Connect close buttons
	if how_to_play_popup:
		var close_button = how_to_play_popup.get_node_or_null("VBoxContainer/CloseButton")
		if close_button:
			close_button.pressed.connect(_on_how_to_play_close_pressed)
	
	if about_popup:
		var close_button = about_popup.get_node_or_null("VBoxContainer/CloseButton")
		if close_button:
			close_button.pressed.connect(_on_about_close_pressed)
	
	# Connect level select popup buttons
	if level_select_popup:
		var close_button = level_select_popup.get_node_or_null("VBoxContainer/CloseButton")
		if close_button:
			close_button.pressed.connect(_on_level_select_close_pressed)
		
		# Connect level buttons (Level 1 = index 1, Level 2 = index 2, etc.)
		var level1_button = level_select_popup.get_node_or_null("VBoxContainer/Level1Button")
		var level2_button = level_select_popup.get_node_or_null("VBoxContainer/Level2Button")
		var level3_button = level_select_popup.get_node_or_null("VBoxContainer/Level3Button")
		var level4_button = level_select_popup.get_node_or_null("VBoxContainer/Level4Button")
		var level5_button = level_select_popup.get_node_or_null("VBoxContainer/Level5Button")
		
		if level1_button:
			level1_button.pressed.connect(func(): _on_level_button_pressed(1))
		if level2_button:
			level2_button.pressed.connect(func(): _on_level_button_pressed(2))
		if level3_button:
			level3_button.pressed.connect(func(): _on_level_button_pressed(3))
		if level4_button:
			level4_button.pressed.connect(func(): _on_level_button_pressed(4))
		if level5_button:
			level5_button.pressed.connect(func(): _on_level_button_pressed(5))
	
	var main_menu_music = load("res://assets/audio/music/AroQuest_FotS_MM_Theme.mp3")
	if main_menu_music:
		var audio_manager = get_node("/root/AudioManager")
		audio_manager.play_music(main_menu_music)

func _play_ui_click():
	var audio_manager = get_node("/root/AudioManager")
	if audio_manager:
		audio_manager.play_ui_click()

func _on_play_button_pressed():
	_play_ui_click()
	# Start at Level 1 (skip tutorial)
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		game_manager.current_level_index = 1
		game_manager.start_level(1)
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

func _on_how_to_play_button_pressed():
	_play_ui_click()
	# Show how to play popup
	if how_to_play_popup:
		how_to_play_popup.visible = true

func _on_how_to_play_close_pressed():
	_play_ui_click()
	if how_to_play_popup:
		how_to_play_popup.visible = false

func _on_options_button_pressed():
	_play_ui_click()
	# Show settings popup
	if settings_popup:
		settings_popup.show_popup()

func _on_about_button_pressed():
	_play_ui_click()
	# Show about popup
	if about_popup:
		about_popup.visible = true

func _on_about_close_pressed():
	_play_ui_click()
	if about_popup:
		about_popup.visible = false

func _on_level_select_button_pressed():
	_play_ui_click()
	# Show level select popup
	if level_select_popup:
		level_select_popup.visible = true

func _on_level_select_close_pressed():
	_play_ui_click()
	if level_select_popup:
		level_select_popup.visible = false

func _on_level_button_pressed(level_number: int):
	_play_ui_click()
	# Close popup
	if level_select_popup:
		level_select_popup.visible = false
	
	# Set the level index (Level 1 = index 1, Level 2 = index 2, etc.)
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		game_manager.current_level_index = level_number
		game_manager.start_level(level_number)
	
	# Load the level scene
	var level_paths = [
		"",  # Index 0 (tutorial, not used here)
		"res://scenes/levels/level_1.tscn",
		"res://scenes/levels/level_2.tscn",
		"res://scenes/levels/level_3.tscn",
		"res://scenes/levels/level_4.tscn",
		"res://scenes/levels/level_5.tscn"
	]
	
	if level_number >= 1 and level_number <= 5:
		var level_path = level_paths[level_number]
		if ResourceLoader.exists(level_path):
			get_tree().change_scene_to_file(level_path)
		else:
			push_error("Level not found: " + level_path)

func _on_quit_button_pressed():
	_play_ui_click()
	get_tree().quit()
