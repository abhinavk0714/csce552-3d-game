extends Node

# UIHelper utility
# Provides helper functions for UI interactions, like playing click sounds
# Can be used across all UI scripts

func play_ui_click():
	var audio_manager = get_node("/root/AudioManager")
	if audio_manager:
		audio_manager.play_ui_click()

