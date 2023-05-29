extends Node2D

var real_frame = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	real_frame += 0.25;
	
	$Sprite2D.frame = floor(real_frame);
	
	if real_frame >= 8:
		$Sprite2D.visible = false;
		$Sprite2D.frame = 0;
		queue_free()
