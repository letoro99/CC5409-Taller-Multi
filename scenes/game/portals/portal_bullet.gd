class_name PBullet
extends Area2D

var direction : Vector2
var portal : Portal
@export var speed : float = 25
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.timeout.connect(on_timer_timeout)

func on_timer_timeout():
	queue_free()

func create_portal(normal_floor: Vector2):
	# Change position portal
	portal.normal_portal = normal_floor
	portal.global_position = global_position
	portal.rotation = Vector2.UP.angle_to(normal_floor)
	
	# Delete PBullet
	global_position = Vector2(-1000,-1000)
	speed = 0
	
	rpc("send_info", {
		"position" : global_position,
		"direction" : Vector2.ZERO,
		"speed" : 0,
		"player" : null
	})

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position += direction * speed
	if is_multiplayer_authority():
		rpc("send_position", global_position)
	
@rpc("unreliable_ordered")
func send_position(pos: Vector2) -> void:
	global_position = pos

@rpc("reliable","any_peer")
func send_info(info: Dictionary) -> void:
	global_position = info.position
	direction = info.direction
	speed = info.speed
	if info.player:
		portal = get_tree().root.get_node("main/Players/" + info.player + "/Portals").get_child(info.portal)
