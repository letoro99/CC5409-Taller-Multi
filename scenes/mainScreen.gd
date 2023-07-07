extends MarginContainer

@onready var play = $menuContainer/play
@onready var credits = $menuContainer/credits
@onready var exit = $menuContainer/exit

# Paths of scenes
var lobby_path = "res://scenes/menus/lobbyScreen.tscn"
var credits_path = "res://scenes/menus/creditsScene.tscn"

func _on_play_pressed() -> void:
	Debug.print("Play pressed")
	get_tree().change_scene_to_file(lobby_path)
	pass # Replace with function body.
	
func _on_credits_pressed() -> void:
	Debug.print("Credits pressed")
	get_tree().change_scene_to_file(credits_path)
	pass # Replace with function body.
	
func _on_exit_pressed() -> void:
	Debug.print("Exit pressed")
	get_tree().quit()

func _ready() -> void:
	Game.delete_data()
	play.pressed.connect(_on_play_pressed)
	credits.pressed.connect(_on_credits_pressed)
	exit.pressed.connect(_on_exit_pressed)
