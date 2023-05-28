extends StaticBody2D

# Variables
var PB_collision_id : int = 0
var max_width : float
var max_height : float
var normal_floor : Vector2 = Vector2.UP

# Children Nodes
@onready var area_2d = $Area2D

# Exports variables
@export var size_cell : int
@export var length_in_cells : int
@export var portal_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	normal_floor = normal_floor.rotated(rotation)
	area_2d.area_entered.connect(on_area2d_enter)
	max_width = (size_cell >> 1) * (length_in_cells - 2) if size_cell % 2 == 0 else (int(length_in_cells >> 1) - 1) * size_cell
	max_height = 0.9 * (size_cell >> 1)
	
	
func _get_vector_spawn(bullet_pos: Vector2) -> Vector2:
	# Calculate the position of the portal inside of this object when a bullet collided 
	
	var portal_position = bullet_pos
	if rotation == 0:
		var rang = [global_position.x - max_width, global_position.x + max_width]
		if bullet_pos.x < rang[0]:
			portal_position.x = rang[0]
		elif  bullet_pos.x > rang[1]:
			portal_position.x = rang[1]
			
		portal_position.y = global_position.y - max_height
		if (global_position.y - bullet_pos.y) < 0:
			portal_position.y = global_position.y ++ max_height
	else:
		var rang = [global_position.y - max_width, global_position.y + max_width]
		if bullet_pos.y < rang[0]:
			portal_position.y = rang[0]
		elif  bullet_pos.y > rang[1]:
			portal_position.y = rang[1]
			
		portal_position.x = global_position.x - max_height
		if (global_position.x - bullet_pos.x) < 0:
			portal_position.x = global_position.x + max_height
			
	return portal_position
	
func on_area2d_enter(area: Area2D) -> void:
	# This function resolve the collision of PBullets
	if is_multiplayer_authority():
		if area is PBullet:
			var actual_normal : Vector2 = normal_floor
			if rotation == 0 and (global_position.y - area.global_position.y) < 0:
				actual_normal = - normal_floor
				
			if rotation == 90 and (global_position.x - area.global_position.x) < 0:
				actual_normal = - normal_floor
				
			area.create_portal(actual_normal, _get_vector_spawn(area.global_position)) # global_position or target_position
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
