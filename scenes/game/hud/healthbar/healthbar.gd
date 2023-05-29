extends ProgressBar


var max_health = 100 
var health = max_health

func setHP(hp):
	health = hp
	
func setMaxHealth(mhp):
	max_health = mhp

func _ready():
	max_value = max_health
	set_health_bar()

func set_health_bar():
	value = health
	
func _input(event: InputEvent):
	if event.is_action_pressed("jump"):
		setHP(health-10)
		set_health_bar()   
	
