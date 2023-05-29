class_name Portal
extends Node2D

var canTeleport : bool = true

@onready var sprite = $Sprite2D
@onready var area = $Area2D
@onready var timer = $Timer

@export var another_portal : Portal
@export var normal_portal : Vector2 = Vector2(1,0)
@export var time_portal_disable : float = 0.08

func disabling_portal():
	canTeleport = false
	await get_tree().create_timer(time_portal_disable).timeout
	canTeleport = true

func on_area_body_entered(body: Node2D) -> void:
	print(body.name);
	if canTeleport and (body is Character or body is Props or body is Crate): # Can be changed with grpous ?
		disabling_portal()
		another_portal.disabling_portal()		
		body.transportate(self, another_portal)

# Called when the node enters the scene tree for the first time.
func _ready():
	area.body_entered.connect(on_area_body_entered)
	
@rpc("any_peer")
func send_info(info: Dictionary) -> void:
	global_position = info.position
	rotation = info.rotation
	normal_portal = info.normal_portal
