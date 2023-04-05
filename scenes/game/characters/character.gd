extends CharacterBody2D

# Constants
const SPEED = 400.0
const JUMP_VELOCITY = -400.0
const ACCELERATION = 35
const DECELERATION = 2
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# RigidBody2D node for testing REMOVE IN THE FUTURE
@onready var bola = preload("res://scenes/game/portals/bola.tscn")

# Character Variable
var directionMove : Vector2 
var angleVelocity : float = 0.0 

func _handle_movement_input() -> void:
	directionMove = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		directionMove += Vector2.LEFT
	
	if Input.is_action_pressed("move_right"):
		directionMove += Vector2.RIGHT
		
	if Input.is_action_pressed("jump"):
		directionMove += Vector2.UP
		
	if Input.is_action_just_pressed("shoot"):
		var element = bola.instantiate()
		element.global_position = get_global_mouse_position()
		get_tree().root.get_node("main").add_child(element)

func _handle_inputs() -> void:
	_handle_movement_input()
	
func transportate(in_portal: Portal, out_portal: Portal):
	global_position = out_portal.global_position
	if in_portal.normal_portal + out_portal.normal_portal != Vector2.ZERO:
		var magnitude = 1.5 * velocity.length()
		velocity = out_portal.normal_portal * magnitude

func _physics_process(delta):
	_handle_inputs()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if  directionMove.y != 0:
		velocity.y = JUMP_VELOCITY
	
	# Using only the horizontal velocity, sample towards the input.
	var hvel = velocity
	var target = directionMove * SPEED
	var acceleration
	hvel.y = 0
	if directionMove.dot(hvel) > 0:
		acceleration = ACCELERATION
	else:
		acceleration = DECELERATION

	hvel = hvel.lerp(target, acceleration * delta)
	velocity.x = hvel.x
	set_velocity(velocity)

	move_and_slide()
