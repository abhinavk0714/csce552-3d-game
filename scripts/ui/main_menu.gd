extends Control

# MainMenu script
# Handles main menu UI interactions and scene transitions

var settings_popup: Panel
var how_to_play_popup: Panel

func _ready():
	var play_button = get_node_or_null("CanvasLayer/VBoxContainer/PlayButton")
	var how_to_play_button = get_node_or_null("CanvasLayer/VBoxContainer/HowToPlayButton")
	var options_button = get_node_or_null("CanvasLayer/VBoxContainer/OptionsButton")
	var quit_button = get_node_or_null("CanvasLayer/VBoxContainer/QuitButton")
	settings_popup = get_node_or_null("CanvasLayer/SettingsPopup")
	how_to_play_popup = get_node_or_null("CanvasLayer/HowToPlayPopup")
	
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
	if how_to_play_button:
		how_to_play_button.pressed.connect(_on_how_to_play_button_pressed)
	if options_button:
		options_button.pressed.connect(_on_options_button_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)
	
	# Connect close buttons
	if how_to_play_popup:
		var close_button = how_to_play_popup.get_node_or_null("VBoxContainer/CloseButton")
		if close_button:
			close_button.pressed.connect(_on_how_to_play_close_pressed)
	
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
	# Reset level progression when starting a new game
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		game_manager.current_level_index = 0
	get_tree().change_scene_to_file("res://scenes/levels/tutorial_level.tscn")

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

func _on_quit_button_pressed():
	_play_ui_click()
	get_tree().quit()
