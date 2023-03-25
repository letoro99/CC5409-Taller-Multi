extends Node

@onready var container = VBoxContainer.new()

func _ready() -> void:
	add_child(container)

func print(message: Variant) -> void:
	if not multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		print_rich("[b]%s:[/b] " % (("Server") if multiplayer.is_server() else "Client"), message)
	else:
		print(message)
	var label = Label.new()
	label.text = str(message)
	container.add_child(label)
	container.move_child(label, 0)
	await get_tree().create_timer(2).timeout
	container.remove_child(label)
	label.queue_free()
