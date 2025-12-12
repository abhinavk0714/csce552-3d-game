extends Node

# GameManager
# Central authority tracking level state, bug counts, timer, and transitions
# Single instance per run; persists data and coordinates scene transitions

var current_level_index: int = 0
var bugs_collected: int = 0
var bugs_total: int = 0
var timer: float = 0.0
var time_limit_per_level: float = 300.0  # 5 minutes in seconds (easily adjustable)
var time_remaining: float = 300.0
var time_expired_handled: bool = false

# Level progression: tutorial -> level_1 -> level_2 -> level_3 -> level_4 -> level_5
var level_paths: Array[String] = [
	"res://scenes/levels/tutorial_level.tscn",
	"res://scenes/levels/level_1.tscn",
	"res://scenes/levels/level_2.tscn",
	"res://scenes/levels/level_3.tscn",
	"res://scenes/levels/level_4.tscn",
	"res://scenes/levels/level_5.tscn"
]

# Computed property for backward compatibility - returns display level number (1-based)
# Tutorial (index 0) shows as 1, level_1 (index 1) shows as 2, etc.
var current_level: int:
	get:
		return current_level_index + 1

signal level_complete
signal level_failed
signal bug_collected
signal time_expired

func _ready():
	get_tree().scene_changed.connect(_on_scene_changed)
	_on_scene_changed()

func _on_scene_changed():
	count_bugs_in_scene()
	
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.name != "MainMenu":
		# Ensure game is not paused when loading a level
		get_tree().paused = false
		
		var level_music = load("res://assets/audio/music/AroQuest_FotS_Level_Theme.mp3")
		if level_music:
			var audio_manager = get_node("/root/AudioManager")
			audio_manager.play_music(level_music)
		# Reset timer and time remaining when entering a new level
		timer = 0.0
		time_remaining = time_limit_per_level
		time_expired_handled = false

func _process(delta):
	# Only increment timer if game is not paused
	if not get_tree().paused:
		timer += delta
		time_remaining -= delta
		
		# Check if time has expired
		if time_remaining <= 0.0 and not time_expired_handled:
			time_remaining = 0.0
			time_expired_handled = true
			time_expired.emit()
			reset_to_tutorial()

func start_level(level_number: int):
	current_level_index = level_number
	bugs_collected = 0
	timer = 0.0
	time_remaining = time_limit_per_level
	time_expired_handled = false
	count_bugs_in_scene()

func complete_level():
	level_complete.emit()
	load_next_level()

func fail_level():
	# When level fails (e.g., time expires), reset to tutorial
	level_failed.emit()
	reset_to_tutorial()

func collect_bug():
	bugs_collected += 1
	bug_collected.emit()
	
	if bugs_collected >= bugs_total and bugs_total > 0:
		# TODO: Trigger special event when all bugs collected
		pass

func reset_level():
	bugs_collected = 0
	timer = 0.0
	time_remaining = time_limit_per_level
	# TODO: Reset player position and platforms

func reset_to_tutorial():
	# Reset to tutorial level when time expires
	current_level_index = 0
	bugs_collected = 0
	timer = 0.0
	time_remaining = time_limit_per_level
	time_expired_handled = false
	get_tree().change_scene_to_file(level_paths[0])

func load_next_level():
	current_level_index += 1
	
	if current_level_index >= level_paths.size():
		# All levels completed - go back to main menu or show victory screen
		print("All levels completed!")
		get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
		return
	
	var next_level_path = level_paths[current_level_index]
	if ResourceLoader.exists(next_level_path):
		get_tree().change_scene_to_file(next_level_path)
	else:
		push_error("Level not found: " + next_level_path)

func count_bugs_in_scene():
	bugs_total = 0
	var root = get_tree().current_scene
	if root:
		_count_bugs_recursive(root)

func _count_bugs_recursive(node: Node):
	if node.get_script():
		var script = node.get_script()
		if script and script.resource_path.ends_with("BugCollectible.gd"):
			bugs_total += 1
	
	for child in node.get_children():
		_count_bugs_recursive(child)
