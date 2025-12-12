extends Node3D

@export var animation_speed_multiplier: float = 3.0
@export var walking_animation_name: String = "walk"

var parent_rigidbody: RigidBody3D
var animation_player: AnimationPlayer

func _ready():
	var gimbal = get_parent()
	if gimbal:
		parent_rigidbody = gimbal.get_node_or_null("../Ball") as RigidBody3D
	
	if not parent_rigidbody:
		push_error("FrogController: Could not find parent RigidBody3D (Ball)")
		return
	
	var frog_node = get_node_or_null("Aro-frog-1")
	if frog_node:
		animation_player = frog_node.get_node_or_null("AnimationPlayer")
	
	scale = Vector3(0.5, 0.5, 0.5)

func _physics_process(delta):
	if not parent_rigidbody:
		return
	
	_update_facing_rotation(delta)
	_update_animation()

func _update_facing_rotation(delta):
	var velocity = parent_rigidbody.linear_velocity
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	var rotation_speed = 5.0
	
	if horizontal_velocity.length() > 0.1:
		var target_direction = horizontal_velocity.normalized()
		var target_rotation_y = atan2(target_direction.x, -target_direction.z)
		var current_y = rotation.y
		rotation.y = lerp_angle(current_y, target_rotation_y, rotation_speed * delta)
	else:
		rotation.y = lerp_angle(rotation.y, 0.0, rotation_speed * delta)

func _update_animation():
	if not animation_player:
		return
	
	var velocity = parent_rigidbody.linear_velocity
	var speed = velocity.length()
	var is_moving = speed > 0.1
	
	if is_moving:
		if walking_animation_name != "" and walking_animation_name in animation_player.get_animation_list():
			if animation_player.current_animation != walking_animation_name:
				animation_player.play(walking_animation_name)
			var speed_scale = clamp(speed / 5.0 * animation_speed_multiplier, 0.5, 3.0)
			animation_player.speed_scale = speed_scale
	else:
		if animation_player.is_playing():
			animation_player.stop()
