class_name Crate
extends RigidBody2D

# Stats
@export var prop_mass : float

# Variables
var collided : bool
var direction : Vector2
var magnitud_force : int = 10

var isTeleporting : bool = false
var outPortal : Portal
var diffPositon : Vector2

var last_velocity : Vector2
var last_pushed : Character = null ;

var MAX_VELOCITY : float = 2500;

var glow_step : float = 0;
var particle = load("res://scenes/game/fx/particle.tscn");

# Children Nodes of Props
@onready var area = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	collided = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# glowing effect for kinetic energy
	var glowForce = min((linear_velocity.length()/1000),1)*abs(sin(glow_step));
	$CardboardGlow.modulate = Color(1,1,1,glowForce);
	
	if linear_velocity.length() >= 1000:
		glow_step += delta;
		
		
		var rng = RandomNumberGenerator.new();
		var newParticle = particle.instantiate();
		
		newParticle.global_position = self.global_position;
		newParticle.velocity = 128*Vector2.from_angle(rng.randf_range(0,2*PI));
		
		get_tree().root.get_node("main").add_child(newParticle);
	
func _physics_process(delta):
	if is_multiplayer_authority():
		if linear_velocity != Vector2.ZERO || angular_velocity != 0:
			rpc("send_update", linear_velocity, global_position, rotation, angular_velocity)
	
	if linear_velocity.length() > 0 and linear_velocity.length() < 2500:
		last_velocity = linear_velocity
		

func push(direction: Vector2):
	pass

func transportate(in_portal: Portal, out_portal: Portal):
	print("Caja transportada desde: ", global_position)
	global_position = out_portal.get_node("SpawnPosition").global_position
	print("hasta: ", global_position)
	# last_velocity.length()
	# apply_impulse(out_portal.normal_portal * min(linear_velocity.length(),MAX_VELOCITY));
	linear_velocity = out_portal.normal_portal * min(linear_velocity.length(),MAX_VELOCITY);
		
func _on_body_entered(body):
	if body is Character:
		var damageCalculation = 0.001*self.linear_velocity.length()*prop_mass;
		if damageCalculation >= 1:
			# deal damage process!
			body.velocity += self.linear_velocity*prop_mass;
			body.dealDamage(damageCalculation);
		
		if linear_velocity.length() >= 1000:
			var rng = RandomNumberGenerator.new();
			for i in range(36):
				var particle = load("res://scenes/game/fx/particle.tscn");
				var newParticle = particle.instantiate();
				newParticle.global_position = self.global_position;
				newParticle.velocity = 256*Vector2.from_angle(rng.randf_range(0,2*PI));
				get_tree().root.get_node("main").add_child(newParticle);
				
		collided = true
		direction = (global_position - body.global_position).normalized()
		last_pushed = body;
		
func _on_body_exited(body):
	if body is Character:
		collided = false
		direction = Vector2.ZERO
	
func _integrate_forces(state) -> void:
	if collided:
		apply_impulse(direction * magnitud_force)
	if isTeleporting:
		var exitSpeed = max(abs(linear_velocity.x), abs(linear_velocity.y))
		linear_velocity = Vector2.ZERO
		apply_central_impulse(outPortal.normal_portal * exitSpeed)
		state.transform = Transform2D(0.0, outPortal.global_position + diffPositon)
		isTeleporting = false
	
@rpc("unreliable_ordered")
func send_update(lin_vel: Vector2, global_pos: Vector2, rot: float, ang_vel: float):
	linear_velocity = lin_vel;
	global_position = global_pos;
	rotation = rot;
	angular_velocity = ang_vel;
