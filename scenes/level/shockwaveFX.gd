extends CanvasLayer

var enabled = false;
var center = Vector2(0,0);
var step = 0;
var size = 0;
var force = 0;
var thickness = -0.13;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func setShockwave(centerPosition):
	var center_x = centerPosition.x;
	var center_y = centerPosition.y;
	var viewport_x = $ColorRect.get_rect().size.x;
	var viewport_y = $ColorRect.get_rect().size.y;
	
	center_x = center_x / viewport_x;
	center_y = center_y / viewport_y;
	
	center_x -= 0.5;
	center_y -= 0.5;
	
	center_x = center_x / 0.5;
	center_y = center_y / 0.5;
	
	print("Setting center at ", center_x, " ", center_y)
	
	enabled = true;
	step = 0;
	size = 0;
	force = 0;
	thickness = 0;
	center = Vector2(center_x,center_y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if enabled:
		step+=1;
		force += 0.005;
		size += 0.03;
		thickness = -0.13;
		
		
		
		if size >= 1000:
			enabled = false;
	
	var material = $ColorRect.material;
	material.set_shader_parameter('center', center);
	material.set_shader_parameter('force', force);
	material.set_shader_parameter('size', size);
	material.set_shader_parameter('thickness', thickness);
	# print(material);
	
	pass
