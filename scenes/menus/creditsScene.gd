extends Control

@onready var button = $VBoxContainer/Button

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/mainScreen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	button.pressed.connect(_on_button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
