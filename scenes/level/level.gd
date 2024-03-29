extends Node2D

### IMPORTS ###
## Scenes
@export var _player_scene : PackedScene
@export var _bullet_scene : PackedScene
@onready var end_label = $EndLabel

## Nodes
@onready var _players = $Players
@onready var _spawners = $Spawner
@onready var health_bars = $HealthBars

## Bullets
@onready var _pbullets = $Pbullets

## Areas
@onready var harmful_area = $harmfulArea

@onready var sprites_characters = [
	load("res://assets/player/character_20x20_red.png"),
	load("res://assets/player/character_20x20_blue.png"),
	load("res://assets/player/character_20x20_green.png"),
	load("res://assets/player/character_20x20_yellow.png"),
	load("res://assets/player/character_20x20_brown.png"),
	load("res://assets/player/character_20x20_orange.png"),
	load("res://assets/player/character_20x20_purple.png"),
	load("res://assets/player/character_20x20_pink.png")
]

var _id_death_players : Array = []
var id_winner 

### SIGNALS ###
func _signal_death_player(id_player):
	_id_death_players.append(id_player)
	Game._death_players += 1
	if Game._players.size() == Game._death_players + 1:
		for player in _players.get_children():
			if player.hp > 0:
				id_winner = player.name
		rpc("end_game", id_winner)
		
### FUNCTIONS ###
## Godot functions
func _ready():
	if is_multiplayer_authority():
		Debug.print("initialization game")
		Game._players.sort()
		Game._death_players = 0
		var player_count = 0;
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
			player.player_death.connect(_signal_death_player)
			
			pbullet_left.name = ("pbleft_" + str(id))
			pbullet_right.name = ("pbright_" + str(id))
			pbullet_left.speed = 0
			pbullet_right.speed = 0
			
			pbullet_left.modulate = Game.PORTALS_COLORS[Game._data_players[id].character][0]
			pbullet_right.modulate = Game.PORTALS_COLORS[Game._data_players[id].character][1]
			
			_pbullets.add_child(pbullet_left)
			_pbullets.add_child(pbullet_right)
			
			player.pbullets = [pbullet_left, pbullet_right]
			_players.add_child(player, true)
			player_count+=1
			
			if id != multiplayer.get_unique_id():
				rpc_id(id, "send_info", { "position" : player.position})
	
		rpc("update_data_game")

## RPC functions	
@rpc("reliable")
func send_info(dic: Dictionary) -> void:
	var id = multiplayer.get_unique_id()
	_players.get_node(str(id)).global_position = dic.position
	
@rpc("reliable","call_local")
func update_data_game() -> void:
	var i = 0
	for key in Game._data_players.keys():
		var value = Game._data_players[key]
		_players.get_node(str(key) + "/Pivot/Sprite2D").texture = sprites_characters[value.character]
		_players.get_node(str(key) + "/Portals").get_child(0).modulate = Game.PORTALS_COLORS[value.character][0]
		_players.get_node(str(key) + "/Portals").get_child(1).modulate = Game.PORTALS_COLORS[value.character][1]
		_players.get_node(str(key)).pbullets = [_pbullets.get_node("pbleft_" + str(key)), _pbullets.get_node("pbright_" + str(key))]
		_players.get_node(str(key)).pbullets[0].modulate = Game.PORTALS_COLORS[value.character][0]
		_players.get_node(str(key)).pbullets[1].modulate = Game.PORTALS_COLORS[value.character][1]
		
		health_bars.get_child(i).modulate = Game.PORTALS_COLORS[value.character][0]
		i += 1

@rpc("reliable", "call_local", "any_peer")
func end_game(id_winner: String) -> void:
	Debug.print("Ganador es: " + str(id_winner))
	end_label.visible = true
	await get_tree().create_timer(3.3).timeout
	Game.id_winner = id_winner
	get_tree().change_scene_to_file("res://scenes/menus/EndScene.tscn")
