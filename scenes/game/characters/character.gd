class_name Character
extends CharacterBody2D

# Constants
const SPEED = 400.0
const JUMP_VELOCITY = -400.0
const ACCELERATION = 35
const DECELERATION = 2
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var portalsList = $Portals

# RigidBody2D node for testing REMOVE IN THE FUTURE
@export var bola : PackedScene

@export var pbullet_scene : PackedScene
@onready var pbullet : PBullet
@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var pivot = $Pivot
@onready var playback = anim_tree.get("parameters/playback")

# Character Variable
var directionMove : Vector2 
var angleVelocity : float = 0.0 
var initialPosition : Vector2
var nextPortal : int = 0

func _ready():
	Debug.print(name)
	set_multiplayer_authority(name.to_int())
	if is_multiplayer_authority():
		anim_tree.active = true
	else:
		anim_tree.active = false

# ONLY FOR TEST RIGIDBODIES 
# DELETE WHEN PROPRS ARE CREATED
func test_bola():
	var element = bola.instantiate()
	element.global_position = get_global_mouse_position()
	get_tree().root.get_node("main").add_child(element)
	
func test_bullet():
	if pbullet == null:
		pbullet = get_tree().root.get_node("main").get_node("Pbullets/pb_" + str(multiplayer.get_unique_id()))
	
	# Modify player's pbullet
	pbullet.global_position = global_position
	pbullet.direction = (get_global_mouse_position() - global_position).normalized()
	pbullet.portal = portalsList.get_child(nextPortal)
	pbullet.speed = 25
	
	# Send info of player's bullet
	pbullet.rpc("send_info", {
		"position" : pbullet.position,
		"direction" : pbullet.direction,
		"speed" : pbullet.speed,
		"portal" : nextPortal,
		"player" : name
	})

	# Change to next portal
	nextPortal = 1 - nextPortal

func _handle_movement_input() -> void:
	directionMove = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		directionMove += Vector2.LEFT
	
	if Input.is_action_pressed("move_right"):
		directionMove += Vector2.RIGHT
		
	if Input.is_action_pressed("jump"):
		directionMove += Vector2.UP
		
	if Input.is_action_just_pressed("shoot"):
		test_bullet()
		
	if Input.is_action_just_pressed("alt_shoot"):
		test_bola()

func _handle_inputs() -> void:
	_handle_movement_input()
	
func transportate(in_portal: Portal, out_portal: Portal):
	global_position = out_portal.global_position
	if in_portal.normal_portal + out_portal.normal_portal != Vector2.ZERO:
		var magnitude = 1.5 * velocity.length()
		velocity = out_portal.normal_portal * magnitude
		
func _physics_process(delta):
	if is_multiplayer_authority():
		_handle_inputs()
			
		# Add the gravity.
		if not is_on_floor():

			velocity.y += gravity * delta

		# Handle Jump.
		if is_on_floor() and directionMove.y != 0:
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
		
		#Animation
		if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			pivot.scale.x = 1
			
		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			pivot.scale.x = -1
		
		if is_on_floor():
			if abs(velocity.x) > 50:
				playback.travel("walk")
			else:
				playback.travel("idle")
		else:
			if velocity.y < 0:
				playback.travel("jump")
			else:
				playback.travel("fall")
		
		# Enviamos la posición del jugador, junto al frame de animación correspondiente
		rpc("send_position",  global_position, $Pivot/Sprite2D.frame, $Pivot.scale.x)

@rpc("unreliable_ordered")
func send_position(vector: Vector2, frame: int, scale: int)  -> void:
	global_position = vector
	$Pivot/Sprite2D.frame = frame
	$Pivot.scale.x = scale
	
