extends Node2D

var nplayers = Game._players.size()
var screen_width = 3200
var y = 2240
var bars

# Called when the node enters the scene tree for the first time.
func _ready():
	bars = [get_node("healthbar1"),get_node("healthbar2"),get_node("healthbar3"),get_node("healthbar4")]
	pass # Replace with function body.

func _process(delta):
	var positions = screen_width/(nplayers+1)
	var i = 0
	for node in bars:
		node.position.x = positions*(i+1)
		node.position.y = y
		if(i+1 > nplayers):
			node.visible = 0
		else:
			node.visible = 1
		i += 1
	pass



	
