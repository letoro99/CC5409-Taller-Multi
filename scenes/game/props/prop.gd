extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func push(direction: Vector2):
	pass

func _on_body_entered(body):
	print("Collision: ", body );
	pass # Replace with function body.
