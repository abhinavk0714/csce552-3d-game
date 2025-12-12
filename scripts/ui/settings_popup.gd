extends Panel

# SettingsPopup script
# Handles volume sliders and settings UI

@onready var music_slider: HSlider = $VBoxContainer/MusicContainer/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/SFXContainer/SFXSlider
@onready var music_label: Label = $VBoxContainer/MusicContainer/MusicValueLabel
@onready var sfx_label: Label = $VBoxContainer/SFXContainer/SFXValueLabel
@onready var close_button: Button = $VBoxContainer/CloseButton

var audio_manager: Node

func _ready():
	# Set process mode to always so it works when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	audio_manager = get_node("/root/AudioManager")
	
	# Initialize sliders to current volume (100% = 1.0)
	if audio_manager:
		music_slider.value = audio_manager.music_volume
		sfx_slider.value = audio_manager.sfx_volume
		_update_music_label(audio_manager.music_volume)
		_update_sfx_label(audio_manager.sfx_volume)
	
	# Connect signals
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	close_button.pressed.connect(_on_close_button_pressed)
	
	# Set buttons and sliders to always process
	if close_button:
		close_button.process_mode = Node.PROCESS_MODE_ALWAYS
	if music_slider:
		music_slider.process_mode = Node.PROCESS_MODE_ALWAYS
	if sfx_slider:
		sfx_slider.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Hide by default
	visible = false

func _on_music_slider_changed(value: float):
	if audio_manager:
		audio_manager.set_music_volume(value)
		_update_music_label(value)

func _on_sfx_slider_changed(value: float):
	if audio_manager:
		audio_manager.set_sfx_volume(value)
		_update_sfx_label(value)

func _update_music_label(value: float):
	var percentage = int(value * 100)
	music_label.text = str(percentage) + "%"

func _update_sfx_label(value: float):
	var percentage = int(value * 100)
	sfx_label.text = str(percentage) + "%"

func _play_ui_click():
	if audio_manager:
		audio_manager.play_ui_click()

func _on_close_button_pressed():
	_play_ui_click()
	visible = false

func show_popup():
	visible = true
	# Refresh values in case they changed
	if audio_manager:
		music_slider.value = audio_manager.music_volume
		sfx_slider.value = audio_manager.sfx_volume
		_update_music_label(audio_manager.music_volume)
		_update_sfx_label(audio_manager.sfx_volume)
