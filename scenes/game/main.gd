extends Node2D

@export var _player_scene : PackedScene
@export var _bullet_scene : PackedScene
@onready var _players = $Players
@onready var _spawners = $Spawner
@onready var _pbullets = $Pbullets

@onready var sprites_characters = [
	load("res://assets/player/character_20x20_red.png"),
	load("res://assets/player/character_20x20_blue.png"),
	load("res://assets/player/character_20x20_green.png"),
	load("res://assets/player/character_20x20_yellow.png")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_multiplayer_authority():
		Debug.print("initialization game")
		Game._players.sort()
		for i in Game._players.size():
			var id = Game._players[i]
			var player : Character = _player_scene.instantiate()
			var pbullet_left : PBullet = _bullet_scene.instantiate()
			var pbullet_right : PBullet = _bullet_scene.instantiate()
			var spawner = _spawners.get_child(i)
			
			player.name = str(id)
			player.global_position = spawner.global_position
			player.get_node("Pivot/Sprite2D").texture = sprites_characters[Game._data_players[id].character]
			player.get_node("Portals").get_child(0).modulate = Game.PORTALS_COLORS[Game._data_players[id].character][0]
			player.get_node("Portals").get_child(1).modulate = Game.PORTALS_COLORS[Game._data_players[id].character][1]
			
			pbullet_left.name = ("pbleft_" + str(id))
			pbullet_right.name = ("pbright_" + str(id))
			
			_pbullets.add_child(pbullet_left)
			_pbullets.add_child(pbullet_right)
			
			player.pbullets = [pbullet_left, pbullet_right]
			_players.add_child(player, true)
			
			if id != multiplayer.get_unique_id():
				rpc_id(id, "send_info", { "position" : player.position})
	
		rpc("update_data_game")
		
@rpc("reliable")
func send_info(dic: Dictionary) -> void:
	var id = multiplayer.get_unique_id()
	_players.get_node(str(id)).global_position = dic.position
	
@rpc("reliable")
func update_data_game():
	for key in Game._data_players.keys():
		var value = Game._data_players[key]
		_players.get_node(str(key) + "/Pivot/Sprite2D").texture = sprites_characters[value.character]
		_players.get_node(str(key) + "/Portals").get_child(0).modulate = Game.PORTALS_COLORS[value.character][0]
		_players.get_node(str(key) + "/Portals").get_child(1).modulate = Game.PORTALS_COLORS[value.character][1]
		_players.get_node(str(key)).pbullets = [_pbullets.get_node("pbleft_" + str(key)), _pbullets.get_node("pbright_" + str(key))]
