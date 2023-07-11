extends Node2D

var velocity = Vector2.ZERO;
var alpha = 1;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var velMag = velocity.length();
	var newVel = velMag - (velMag*delta/2);
	velocity = newVel*velocity.normalized()
	
	alpha -= (alpha)*delta*3;
	
	if alpha <= 0.05:
		queue_free();
	
		
	var prevCol = $Fxsparkle.modulate;
	$Fxsparkle.modulate = Color(prevCol.r, prevCol.g, prevCol.b, alpha);
		
	global_position += velocity*delta;
	pass
