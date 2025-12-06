extends Control

# MainMenu script
# Handles main menu UI interactions and scene transitions

var settings_popup: Panel

func _ready():
	var play_button = get_node_or_null("CanvasLayer/VBoxContainer/PlayButton")
	var level_select_button = get_node_or_null("CanvasLayer/VBoxContainer/LevelSelectButton")
	var options_button = get_node_or_null("CanvasLayer/VBoxContainer/OptionsButton")
	var quit_button = get_node_or_null("CanvasLayer/VBoxContainer/QuitButton")
	settings_popup = get_node_or_null("CanvasLayer/SettingsPopup")
	
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
	if level_select_button:
		level_select_button.pressed.connect(_on_level_select_button_pressed)
	if options_button:
		options_button.pressed.connect(_on_options_button_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)
	
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
	get_tree().change_scene_to_file("res://scenes/levels/level_2.tscn")

func _on_level_select_button_pressed():
	_play_ui_click()
	# TODO: Open level select menu
	print("Level select button pressed")

func _on_options_button_pressed():
	_play_ui_click()
	# Show settings popup
	if settings_popup:
		settings_popup.show_popup()

func _on_quit_button_pressed():
	_play_ui_click()
	get_tree().quit()
