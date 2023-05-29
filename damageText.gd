extends Control


@onready var damage : int;

# constants
@onready var VISIBILITY_TIME : int = 3;

# Called when the node enters the scene tree for the first time.
func _ready():
	# await get_tree().create_timer(VISIBILITY_TIME);
	# queue_free();
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.text = str(damage);
	pass
