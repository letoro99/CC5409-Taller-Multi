class_name Character
extends CharacterBody2D

# Constants
const SPEED = 400.0
const JUMP_VELOCITY = -400.0
const ACCELERATION = 35
const DECELERATION = 2

# Variables
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_velocity : Vector2
var _directionAim : Vector2

# Player stats 
var maxHP = 100;

# Player current effects
var hp = maxHP;				# player health
var stun = 0;				# stun time
var lives = 0;				# to implement: lives

var lastDamager = null;

@onready var portalsList = $Portals

# RigidBody2D node for testing REMOVE IN THE FUTURE
@export var bola : PackedScene
@export var pbullet_scene : PackedScene
@onready var pbullets : Array
@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var pivot = $Pivot
@onready var playback = anim_tree.get("parameters/playback")

# Character Variable
var directionMove : Vector2 
var angleVelocity : float = 0.0 
var initialPosition : Vector2

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
	
func get_angle_two_vectors(vector1: Vector2, vector2: Vector2):
	return vector1.angle_to(vector2)

func get_substraction_vectors(vector1: Vector2, vector2: Vector2):
	return (vector1 - vector2).normalized()
	
func _set_position_pg():
	_directionAim = get_substraction_vectors(get_global_mouse_position(), self.global_position)
	get_node("Sprite_PG").global_position = global_position + 100 * _directionAim
	get_node("Sprite_PG").rotation_degrees = rad_to_deg(get_angle_two_vectors(Vector2.UP, _directionAim))
	if get_node("Sprite_PG").rotation_degrees < 0:
		get_node("Sprite_PG").flip_h = true
	else:
		get_node("Sprite_PG").flip_h = false
	
func shoot_pbullet(index: int):
	var pbullet = pbullets[index]
	Debug.print(pbullet.name)
	
	# Modify player's pbullet
	pbullet.global_position = global_position
	pbullet.direction = (get_global_mouse_position() - global_position).normalized()
	pbullet.portal = portalsList.get_child(index)
	pbullet.speed = 45
	
	# Send info of player's bullet
	pbullet.rpc("send_info", {
		"position" : pbullet.position,
		"direction" : pbullet.direction,
		"speed" : pbullet.speed,
		"portal" : index,
		"player" : name
	})

func _handle_movement_input() -> void:
	directionMove = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		directionMove += Vector2.LEFT
	
	if Input.is_action_pressed("move_right"):
		directionMove += Vector2.RIGHT
		
	if Input.is_action_pressed("jump"):
		directionMove += Vector2.UP
		
	if Input.is_action_just_pressed("shoot"):
		shoot_pbullet(0)
		
	if Input.is_action_just_pressed("alt_shoot"):
		shoot_pbullet(1)
		
	if Input.is_key_pressed(KEY_R):
		global_position = get_parent().get_parent().get_node('Spawner/1stSpawner').global_position
		

func _handle_inputs() -> void:
	_handle_movement_input()
	
func transportate(in_portal: Portal, out_portal: Portal):
	global_position = out_portal.get_node("SpawnPosition").global_position
	if velocity.length() == 0:
		velocity = last_velocity
		
	Debug.print(velocity)
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
		
		# Portal Gun positions
		_set_position_pg()
		rpc("_send_position_pg", {"position": get_node("Sprite_PG").global_position, "rotation": get_node("Sprite_PG").rotation_degrees, "flip": get_node("Sprite_PG").flip_h})
		
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
		if velocity.length() > 0 and velocity.length() < 2500:
			last_velocity = velocity

# =============== HEALTH API =================
func hpChanged():
	# here we should send the signals 
	# to the corresponding nodes that read HP
	
	if hp <= 0:
		queue_free();
		pass
		# process death sequence

func decreaseHP(amount: float):
	# decreases HP in a certain amount 
	hp -= amount;
	self.hpChanged()

# =============== DAMAGE API =================
func dealDamage(damage: float, damager: Node = null):
	# here we would implement extra effects
	decreaseHP(damage);
	
	if damager:
		lastDamager = damager;
	



@rpc("unreliable_ordered")
func send_position(vector: Vector2, frame: int, _scale: int)  -> void:
	global_position = vector
	$Pivot/Sprite2D.frame = frame
	$Pivot.scale.x = _scale

@rpc("unreliable_ordered")	
func _send_position_pg(data: Dictionary):
	get_node("Sprite_PG").global_position = data.position
	get_node("Sprite_PG").rotation_degrees = data.rotation
	get_node("Sprite_PG").flip_h = data.flip
	pass
