extends Area2D

@onready var collision_shape_2d = $CollisionShape2D

## Signals functions
func _on_body_entered(body: Node2D):
	print(body)
	if body is Character:
		body.dealDamage(1000, self)

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
