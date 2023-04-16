extends StaticBody2D

# FLOOR TO TEST PORTALS INSTANTIATIONS
@onready var area_2d = $Area2D
@export var normal_floor : Vector2
var rotation_angle : float 
@export var portal_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	rotation_angle = Vector2.RIGHT.angle_to(normal_floor)
	area_2d.area_entered.connect(on_area2d_enter)
	
func on_area2d_enter(area: Area2D):
	if area is PBullet:
		area.create_portal(normal_floor)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
