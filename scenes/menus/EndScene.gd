extends MarginContainer

@onready var lobby = $menuContainer2/Lobby
@onready var main_menu = $menuContainer2/MainMenu

@onready var label_winner = $menuContainer/MarginContainer2/Label

func _on_lobby_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/lobbyScreen.tscn")

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/mainScreen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	main_menu.pressed.connect(_on_main_menu_pressed)
	
	var id_winner = Game.id_winner
	
	label_winner.text = Game.CHARACTER_NAME[Game._data_players[id_winner.to_int()].character]
	
	multiplayer.multiplayer_peer.close()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
