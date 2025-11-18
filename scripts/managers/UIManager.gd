extends CanvasLayer

# UIManager
# Manages HUD updates, menu toggles (pause/resume), and screen messages
# Bridges GameManager <-> Canvas UI elements
# Handles localization hooks and UI transitions if needed

@export var hud: Control
@export var pause_menu: Control
@export var main_menu: Control

var timer_label: Label
var bugs_label: Label
var lives_label: Label
var level_label: Label

func _ready():
	if hud:
		timer_label = hud.get_node_or_null("TimerLabel")
		bugs_label = hud.get_node_or_null("BugsLabel")
		lives_label = hud.get_node_or_null("LivesLabel")
		level_label = hud.get_node_or_null("LevelLabel")
	else:
		timer_label = get_node_or_null("TimerLabel")
		bugs_label = get_node_or_null("BugsLabel")
		lives_label = get_node_or_null("LivesLabel")
		level_label = get_node_or_null("LevelLabel")
	
	var game_manager = get_node("/root/GameManager")
	game_manager.bug_collected.connect(_on_bug_collected)
	game_manager.level_complete.connect(_on_level_complete)
	game_manager.level_failed.connect(_on_level_failed)
	
	update_hud()

func _process(_delta):
	update_timer(get_node("/root/GameManager").timer)

func update_hud():
	var game_manager = get_node("/root/GameManager")
	update_timer(game_manager.timer)
	update_bugs(game_manager.bugs_collected, game_manager.bugs_total)
	update_lives(game_manager.lives)
	update_level(game_manager.current_level)

func update_timer(time: float):
	if timer_label:
		var minutes = int(time) / 60
		var seconds = int(time) % 60
		var milliseconds = int((time - int(time)) * 100)
		timer_label.text = "Time: %02d:%02d.%02d" % [minutes, seconds, milliseconds]

func update_bugs(collected: int, total: int):
	if bugs_label:
		bugs_label.text = "Bugs: %d / %d" % [collected, total]

func update_lives(lives: int):
	if lives_label:
		lives_label.text = "Lives: %d" % lives

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
	update_bugs(game_manager.bugs_collected, game_manager.bugs_total)

func _on_level_complete():
	# TODO: Show level complete message
	pass

func _on_level_failed():
	# TODO: Show game over message
	pass
