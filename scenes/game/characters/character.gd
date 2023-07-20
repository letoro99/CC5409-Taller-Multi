class_name Character
extends CharacterBody2D

# Constants Character
const SPEED = 400.0
const JUMP_VELOCITY = -400.0
const ACCELERATION = 35
const DECELERATION = 2

# Signals
signal player_death(id_player)

# References
@onready var healthbars = [
	get_tree().root.get_node("main/HealthBars/healthbar1"),
	get_tree().root.get_node("main/HealthBars/healthbar2"),
	get_tree().root.get_node("main/HealthBars/healthbar3"),
	get_tree().root.get_node("main/HealthBars/healthbar4")
]

@onready var myHealthBar = null;

# Variables
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_velocity : Vector2
var _directionAim : Vector2

# Player stats 
var maxHP = 20;

# Player current effects
var hp = maxHP;				# player health
var stun = 0;				# stun time
var lives = 0;				# to implement: lives
var hit_immune = 0;			# gives immunity to hits for n frames

var lastDamager = null;

# ===== Exports Variables and Onready ===== #
@onready var portalsList = $Portals
@export var pbullet_scene : PackedScene
@onready var pbullets : Array
@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var pivot = $Pivot
@onready var playback = anim_tree.get("parameters/playback")
@onready var ray_cast = $RayCast2D

# Character Variable
var directionMove : Vector2 
var angleVelocity : float = 0.0 
var initialPosition : Vector2
var player_alive : bool = true

func get_player_index():
	var nodes = get_parent().get_children();
	var names = []
	for i in nodes:
		names.append(i.name.to_int());
	names.sort();
	return names.find(self.name.to_int());
		
func _ready():
	Debug.print(name)
	set_multiplayer_authority(name.to_int())
	if is_multiplayer_authority():
		anim_tree.active = true
	else:
		anim_tree.active = false
	
	await get_tree().create_timer(1).timeout;
	myHealthBar = healthbars[get_player_index()];
	player_alive = true

func get_angle_two_vectors(vector1: Vector2, vector2: Vector2):
	# Returns a Vector2 with the angle in randians between two Vector2
	return vector1.angle_to(vector2)

func get_substraction_vectors(vector1: Vector2, vector2: Vector2):
	# Returns a Vector2 with the 
	return (vector1 - vector2).normalized()
	
func _set_position_portalgun():
	# This functions set the posiiton and rotation of portal gun sprite
	_directionAim = get_substraction_vectors(get_global_mouse_position(), self.global_position)
	ray_cast.target_position = _directionAim * 10000

	get_node("Sprite_PG").global_position = global_position + 100 * _directionAim
	get_node("Sprite_PG").rotation_degrees = rad_to_deg(get_angle_two_vectors(Vector2.UP, _directionAim))
	if get_node("Sprite_PG").rotation_degrees < 0:
		get_node("Sprite_PG").flip_h = true
	else:
		get_node("Sprite_PG").flip_h = false
	
func shoot_pbullet(index: int):
	# This function create a bullet the parameters of the character and mouse's position
	var pbullet = pbullets[index]

	if pbullet.enabled:
		pbullet.enabled = false
		
		# Modify player's pbullet
		pbullet.global_position = global_position
		pbullet.direction = (get_global_mouse_position() - global_position).normalized()
		pbullet.portal = portalsList.get_child(index)
		pbullet.speed = 40
		pbullet.target_position = ray_cast.get_collision_point()
		pbullet.valid_target = ray_cast.get_collider().get_parent().PB_collision_id == 0
		
		# Send info of player's bullet
		pbullet.rpc("send_info", {
			"position" : pbullet.position,
			"direction" : pbullet.direction,
			"speed" : pbullet.speed,
			"target" : pbullet.target_position,
			"valid" : pbullet.valid_target,
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
		print(name, "resetted")
		global_position = get_parent().get_parent().get_node('Spawner/1stSpawner').global_position
		
func _handle_inputs() -> void:
	if player_alive:
		_handle_movement_input()
	
func transportate(in_portal: Portal, out_portal: Portal):
	# This function resolve the position and velocuity of a character when use a portal
	global_position = out_portal.get_node("SpawnPosition").global_position
	if velocity.length() == 0:
		velocity = last_velocity
		
	if in_portal.normal_portal + out_portal.normal_portal != Vector2.ZERO:
		var magnitude = 1.5 * velocity.length()
		velocity = out_portal.normal_portal * magnitude
		
func _physics_process(delta):
	if hit_immune > 0:
		$Pivot/Sprite2D.visible = !$Pivot/Sprite2D.visible;
		hit_immune -= delta;
	else:
		hit_immune = 0;
		$Pivot/Sprite2D.visible = true;
	
	if is_multiplayer_authority() and player_alive:
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
		if velocity.length() > 0 and velocity.length() < 2500:
			last_velocity = velocity
			
		# Portal Gun positions
		_set_position_portalgun()
		rpc("_send_position_pg", {"position": get_node("Sprite_PG").global_position, "rotation": get_node("Sprite_PG").rotation_degrees, "flip": get_node("Sprite_PG").flip_h, "target": ray_cast.target_position})
		
# =============== HEALTH API =================
func hpChanged():
	# here we should send the signals 
	# to the corresponding nodes that read HP
	if myHealthBar == null:
		myHealthBar = healthbars[get_player_index()]
	myHealthBar.setMaxHealth(maxHP);
	myHealthBar.setHP(hp);
	myHealthBar.set_health_bar();
	if is_multiplayer_authority():
		Debug.print("hpChanged para %s" % name);
		rpc("send_stats", int(round(hp)), int(round(hit_immune)));
	print(myHealthBar.name)
	
	if hp <= 0:
		player_alive = false
		player_death.emit(name)
		# queue_free();
		var explosion = load("res://scenes/game/explosion/explosion.tscn");
		var new_explosion = explosion.instantiate();
		new_explosion.global_position = global_position;
		get_tree().root.get_node("main").add_child(new_explosion);
		global_position = Vector2(-1000, -1000)
		# process death sequence

func decreaseHP(amount: float):
	# decreases HP in a certain amount 
	hp -= amount;
	self.hpChanged()

# =============== DAMAGE API =================
func dealDamage(damage: float, damager: Node = null):
	if is_multiplayer_authority():
		# here we would implement extra effects
		if hit_immune <= 0:
			hit_immune = 2;
			decreaseHP(damage);
		#var damageText = load("res://scenes/game/damageText/damage_text.tscn");
		#get_tree().root.get_node("main").add_child(damageText.instantiate());
		#Debug.print(damage);
		# damageText.global_position = self.global_position;
		#damageText.damage = int(round(damage));
			if damager:
				lastDamager = damager;
				
@rpc("any_peer","unreliable_ordered")
func rpc_test(texto: String) -> void:
	Debug.print("Recibido el mensaje: %s" % texto)

@rpc("reliable")
func send_stats(hp_value: int, hit_immunity: int) -> void:
	Debug.print("Recibido send_stats para nodo %s" % name)
	hp = hp_value; 
	hit_immune = hit_immunity
	hpChanged();

@rpc("unreliable_ordered")
func send_position(vector: Vector2, frame: int, _scale: int)  -> void:
	global_position = vector
	$Pivot/Sprite2D.frame = frame
	$Pivot.scale.x = _scale

@rpc("unreliable_ordered")	
func _send_position_pg(data: Dictionary) -> void:
	get_node("Sprite_PG").global_position = data.position
	get_node("Sprite_PG").rotation_degrees = data.rotation
	get_node("Sprite_PG").flip_h = data.flip
