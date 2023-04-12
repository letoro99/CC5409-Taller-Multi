extends Node2D

@export var _player_scene : PackedScene
@onready var _players = $Players
@onready var _spawners = $Spawner

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_multiplayer_authority():
		Game._players.sort()
		for i in Game._players.size():
			var id = Game._players[i]
			var player : Character = _player_scene.instantiate()
			player.name = str(id)
			var spawner = _spawners.get_child(i)
			player.global_position = spawner.global_position
			_players.add_child(player)
