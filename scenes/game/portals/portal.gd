class_name Portal
extends Node2D

#Variables
var canTeleport : bool = true
var PB_collision_id : int = 1

# Children Nodes
@onready var sprite = $Sprite2D
@onready var area = $Area2D
@onready var timer = $Timer

# Exports variables
@export var another_portal : Portal
@export var normal_portal : Vector2 = Vector2(1,0)
@export var time_portal_disable : float = 0.08

func disabling_portal():
	# Disable the portals when a object is teleporting using this and the other portal
	canTeleport = false
	await get_tree().create_timer(time_portal_disable).timeout
	canTeleport = true

func on_area_body_entered(body: Node2D) -> void:
	if (canTeleport and another_portal.canTeleport) and (body is Character or body is Props or body is Crate): # Can be changed with grpous ?
		
		disabling_portal()
		another_portal.disabling_portal()		
		body.transportate(self, another_portal)

# Called when the node enters the scene tree for the first time.
func _ready():
	area.body_entered.connect(on_area_body_entered)
	canTeleport = false
	
@rpc("any_peer")
func send_info(info: Dictionary) -> void:
	global_position = info.position
	rotation = info.rotation
	normal_portal = info.normal_portal
	canTeleport = true
