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
	pass

func _process(delta):
	pass

func start_level(level_number: int):
	pass

func complete_level():
	pass

func fail_level():
	pass

func collect_bug():
	pass

func reset_level():
	pass

func load_next_level():
	pass
