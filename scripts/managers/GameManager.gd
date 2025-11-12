extends Node

# GameManager
# Central authority tracking level state, bug counts, timer, lives, and transitions
# Single instance per run; persists data and coordinates scene transitions

var current_level: int = 1
var bugs_collected: int = 0
var bugs_total: int = 0
var timer: float = 0.0
var lives: int = 3

signal level_complete
signal level_failed
signal bug_collected

func _ready():
	get_tree().scene_changed.connect(_on_scene_changed)
	_on_scene_changed()

func _on_scene_changed():
	count_bugs_in_scene()
	
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.name != "MainMenu":
		var level_music = load("res://assets/audio/music/AroQuest_FotS_Level_Theme.mp3")
		if level_music:
			var audio_manager = get_node("/root/AudioManager")
			audio_manager.play_music(level_music)
		start_level(1)

func _process(delta):
	timer += delta

func start_level(level_number: int):
	current_level = level_number
	bugs_collected = 0
	timer = 0.0
	count_bugs_in_scene()

func complete_level():
	level_complete.emit()
	# TODO: Handle level completion

func fail_level():
	lives -= 1
	if lives <= 0:
		level_failed.emit()
		# TODO: Handle game over
	else:
		reset_level()

func collect_bug():
	bugs_collected += 1
	bug_collected.emit()
	
	if bugs_collected >= bugs_total and bugs_total > 0:
		# TODO: Trigger special event when all bugs collected
		pass

func reset_level():
	bugs_collected = 0
	timer = 0.0
	# TODO: Reset player position and platforms

func load_next_level():
	current_level += 1
	start_level(current_level)
	# TODO: Actually load the next level scene

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
