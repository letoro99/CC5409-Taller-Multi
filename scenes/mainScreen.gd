extends MarginContainer

@onready var play = $menuContainer/play
@onready var credits = $menuContainer/credits
@onready var exit = $menuContainer/exit
@onready var logo = $LogoPortalCombat


var iteration : int = 0
var diff_vector_logo : Vector2 = Vector2(0, 0.15)
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
	
func _process(delta):
	logo.global_position += diff_vector_logo
	iteration += 1
	if iteration % 50 == 0:
		diff_vector_logo *= -1
		iteration = 1
