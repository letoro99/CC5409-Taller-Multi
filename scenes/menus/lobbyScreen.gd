extends MarginContainer


const MAX_PLAYERS = 4
const PORT = 5000

@onready var user = $Start/MarginContainer/Start/GridContainer/User
@onready var color_name = $Start/MarginContainer/Start/GridContainer/ColorName
@onready var ip = $Start/MarginContainer/Start/GridContainer/IP

@onready var host = $Start/MarginContainer/Start/HBoxContainer/Host
@onready var join = $Start/MarginContainer/Start/HBoxContainer/Join

@onready var start = $Start
@onready var pending = $Pending

@onready var players_list = $Pending/PanelContainer2/MarginContainer/Pending/PanelContainer/PlayersList
@onready var play = $Pending/HBoxContainer/Play

# { id: true }
var status = {1 : false}

func _ready():
	host.pressed.connect(_on_host_pressed)
	join.pressed.connect(_on_join_pressed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	start.show()
	pending.hide()
	user.text = OS.get_environment("USERNAME")
	
	play.pressed.connect(_on_play_pressed)
	
	Game.upnp_completed.connect(_on_upnp_completed)

func _on_upnp_completed(status) -> void:
	print(status)

func _on_host_pressed() -> void:
	Debug.print("host")
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(PORT, MAX_PLAYERS)
	print(err)
	multiplayer.multiplayer_peer = peer
	start.hide()
	_add_player(user.text, color_name.get_picker().color, multiplayer.get_unique_id())
	pending.show()


func _on_join_pressed() -> void:
	Debug.print("join")
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip.text, PORT)
	print(err)
	multiplayer.multiplayer_peer = peer
	start.hide()
	_add_player(user.text, color_name.get_picker().color, multiplayer.get_unique_id())
	pending.show()

func _on_connected_to_server() -> void:
	Debug.print("connected_to_server")


func _on_connection_failed() -> void:
	Debug.print("connection_failed")


func _on_peer_connected(id: int) -> void:
	Debug.print("peer_connected %d" % id)
	rpc_id(id, "send_info", { "name": user.text , "color_name": color_name.get_picker().color})
	if multiplayer.is_server():
		status[id] = false

func _on_peer_disconnected(id: int) -> void:
	Debug.print("peer_disconnected %d" % id)
	
func _on_server_disconnected() -> void:
	print("server_disconnected")

func _add_player(nameString: String, color: Color, id: int):
	var container = HBoxContainer.new()
	var label = Label.new()
	var colorRect = ColorRect.new()
	colorRect.name = "status"
	colorRect.color = Color.RED
	colorRect.custom_minimum_size  = Vector2(20, 0)
	container.name = str(id)
	label.modulate = color
	label.text = nameString
	container.add_child(colorRect)
	container.add_child(label)
	players_list.add_child(container)
	Game._players.append(id)

@rpc("any_peer", "reliable")
func send_info(info: Dictionary) -> void:
	var color_name = info.color_name
	var id = multiplayer.get_remote_sender_id()
	_add_player(info.name, color_name, id)

func _paint_ready(id: int) -> void:
	for child in players_list.get_children():
		if child.name == str(id):
			child.get_node("status").color = Color.GREEN

func _on_play_pressed() -> void:
	rpc("player_ready")
	_paint_ready(multiplayer.get_unique_id())

@rpc("reliable", "any_peer", "call_local")
func player_ready():
	var id = multiplayer.get_remote_sender_id()
	_paint_ready(id)
	if multiplayer.is_server():
		status[id] = not status[id]
		var all_ok = true
		for ok in status.values():
			all_ok = all_ok and ok
		if all_ok:
			rpc("start_game")

@rpc("any_peer", "call_local", "reliable")
func start_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")
