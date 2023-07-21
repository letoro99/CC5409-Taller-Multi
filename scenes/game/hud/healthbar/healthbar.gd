extends Control
@onready var healthbar = $healthbar

var max_health = 100 
var health = max_health

func setHP(hp):
	health = hp
	
func setMaxHealth(mhp):
	max_health = mhp

func _ready():
	healthbar.max_value = max_health
	set_health_bar()

func set_health_bar():
	healthbar.max_value = max_health
	healthbar.value = health
	
func _input(event: InputEvent):
	pass
	
