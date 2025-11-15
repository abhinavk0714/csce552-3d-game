extends Area3D

@export var objects_to_reset: Array[NodePath] = []

signal body_collided(body: Node3D)

var _bodies_in_area = []

func _ready():
	body_entered.connect(_on_body_entered)

#func _process(delta):
	#body_entered.connect(_on_body_entered)
	#if body_entered:
		#print("hi")


func _on_body_entered(body):
	if body is RigidBody3D:
		print("Body fell:", body.name)
		body_collided.emit(body)
		#body.restart()
		#print(get_path())
