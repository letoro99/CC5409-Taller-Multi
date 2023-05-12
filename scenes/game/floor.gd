extends StaticBody2D

# FLOOR TO TEST PORTALS INSTANTIATIONS
@onready var area_2d = $Area2D
var normal_floor : Vector2 = Vector2.UP
@export var portal_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	normal_floor = normal_floor.rotated(rotation)
	area_2d.area_entered.connect(on_area2d_enter)
	
func on_area2d_enter(area: Area2D):
	if is_multiplayer_authority():
		if area is PBullet:
			var pos = Vector2(area.global_position.x, area.global_position.y)
			var actual_normal : Vector2 = normal_floor
			if rotation == 0 and (global_position.y - area.global_position.y) < 0:
				actual_normal = - normal_floor
				
			if rotation == 90 and (global_position.x - area.global_position.x) < 0:
				actual_normal = - normal_floor
				
			area.create_portal(actual_normal, pos)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
