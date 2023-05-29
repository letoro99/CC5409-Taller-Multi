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

# Children Nodes of Props
@onready var area = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	collided = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
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
		if damageCalculation >= 1 and last_pushed != body:
			# deal damage process!
			body.velocity += self.linear_velocity*prop_mass;
			body.dealDamage(damageCalculation);
			
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
	
