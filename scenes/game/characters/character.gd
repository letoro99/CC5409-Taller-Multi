extends CharacterBody2D

# Constants
const SPEED = 400.0
const JUMP_VELOCITY = -400.0
const ACCELERATION = 30
const DECELERATION = 5
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Character Variable
var directionMove : Vector2 

func _handle_movement_input() -> void:
	directionMove = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		directionMove += Vector2.LEFT
	
	if Input.is_action_pressed("move_right"):
		directionMove += Vector2.RIGHT
		
	if Input.is_action_pressed("jump"):
		directionMove += Vector2.UP

func _handle_inputs() -> void:
	_handle_movement_input()

func _physics_process(delta):
	_handle_inputs()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if directionMove.y != 0 and is_on_floor():
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
