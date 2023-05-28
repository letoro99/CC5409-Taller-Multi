extends RigidBody2D

# Variables
var collided : bool
var direction : Vector2
var magnitud_force : int = 10

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

func push(direction: Vector2):
	pass

func _on_body_entered(body):
	print("Collision: ", body )
	if body is Character:
		collided = true
		direction = (global_position - body.global_position).normalized()
		
func _on_body_exited(body):
	print("Collision: ", body )
	if body is Character:
		collided = false
		direction = Vector2.ZERO
	
func _integrate_forces(state) -> void:
	if collided:
		apply_impulse(direction * magnitud_force)
