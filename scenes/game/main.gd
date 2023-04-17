extends Node2D

@export var _player_scene : PackedScene
@export var _bullet_scene : PackedScene
@onready var _players = $Players
@onready var _spawners = $Spawner
@onready var _pbullets = $Pbullets

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_multiplayer_authority():
		print("initialization game")
		Game._players.sort()
		for i in Game._players.size():
			var id = Game._players[i]
			var player : Character = _player_scene.instantiate()
			var pbullet : PBullet = _bullet_scene.instantiate()
			var spawner = _spawners.get_child(i)
			player.name = str(id)
			player.global_position = spawner.global_position
			pbullet.name = ("pb_" + str(id))
			_pbullets.add_child(pbullet)
			_players.add_child(player, true)
			if id != multiplayer.get_unique_id():
				rpc_id(id, "send_info", { "position" : player.position})
				
			
@rpc("reliable")
func send_info(dic: Dictionary) -> void:
	_players.get_node(str(multiplayer.get_unique_id())).global_position = dic.position
