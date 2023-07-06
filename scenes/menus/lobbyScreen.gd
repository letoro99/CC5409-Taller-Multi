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
@onready var level_selector = $Pending/PanelContainer/VBoxContainer/levelSelector

@onready var players_list = $Pending/PanelContainer2/MarginContainer/Pending/PanelContainer/PlayersList
@onready var play = $Pending/HBoxContainer/Play
@onready var option_button = $Pending/PanelContainer/VBoxContainer/OptionButton
@onready var option_level = $Pending/PanelContainer/VBoxContainer/levelSelector/OptionButton

@onready var timer = $Timer

# { id: true }
var status = {1 : false}
var local_status = false
var options_levels_path = [
	"res://scenes/level/level1.tscn", 	# Laboratory
	"res://scenes/level/level2.tscn",	# Cave
	"res://scenes/level/level3.tscn"	# Castle
]
var id_level : int
var level_path : String

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
	level_selector.hide()
	user.text = OS.get_environment("USERNAME")
	
	play.pressed.connect(_on_play_pressed)
	option_button.item_selected.connect(_character_changed)
	option_level.item_selected.connect(_level_changed)
	level_path = options_levels_path[0]
	option_level.selected = 0
	
	Game.upnp_completed.connect(_on_upnp_completed)
	timer.timeout.connect(_on_timer_timeout)

func _on_upnp_completed(state) -> void:
	print(state)

func _on_host_pressed() -> void:
	Debug.print("host")
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(PORT, MAX_PLAYERS)
	print(err)
	multiplayer.multiplayer_peer = peer
	start.hide()
	_add_player(user.text, color_name.get_picker().color, multiplayer.get_unique_id())
	pending.show()
	level_selector.show()

func _on_join_pressed() -> void:
	Debug.print("join")
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip.text, PORT)
	print(err)
	multiplayer.multiplayer_peer = peer
	start.hide()
	_add_player(user.text, color_name.get_picker().color, multiplayer.get_unique_id())
	pending.show()
	level_selector.show()
	option_level.disabled = true

func _on_connected_to_server() -> void:
	Debug.print("connected_to_server")

func _on_connection_failed() -> void:
	Debug.print("connection_failed")

func _on_peer_connected(id: int) -> void:
	Debug.print("peer_connected %d" % id)
	rpc_id(id, "send_info", { "name": user.text , "color_name": color_name.get_picker().color})
	if multiplayer.is_server():
		status[id] = false
		timer.start(0.3)

func _on_peer_disconnected(id: int) -> void:
	Debug.print("peer_disconnected %d" % id)
	
func _on_server_disconnected() -> void:
	print("server_disconnected")

func _on_timer_timeout() -> void:
	if is_multiplayer_authority():
		rpc("send_level_data", id_level)
		rpc("send_actual_data", Game._data_players, status)

func _get_color_status(state: bool):
	if state:
		return Color.GREEN
	else:
		return Color.RED

func _add_player(nameString: String, color: Color, id: int):
	var container = HBoxContainer.new()
	var label = Label.new()
	var colorRect = ColorRect.new()
	var character = TextureRect.new()
	
	colorRect.name = "status"
	colorRect.color = Color.RED
	colorRect.custom_minimum_size  = Vector2(20, 0)
	
	label.modulate = color
	label.text = nameString
	
	character.name = "character"
	character.texture = Game.CHARACTER_PROFILES[0]
	
	container.name = str(id)
	container.add_child(colorRect)
	container.add_child(label)
	container.add_child(character)
	
	players_list.add_child(container)
	Game._players.append(id)
	Game._bullets.append(id)
	Game._name_players[id] = nameString
	
	if is_multiplayer_authority():
		var id_selected = option_button.get_selectable_item()
		if id == multiplayer.get_unique_id():
			option_button.select(id_selected)
			players_list.get_node(str(id) + "/character").texture = Game.CHARACTER_PROFILES[id_selected]
		option_button.set_item_disabled(id_selected, true)
		players_list.get_node(str(id) + "/character").texture = Game.CHARACTER_PROFILES[id_selected]
		Game._data_players[id] = {"character": id_selected}
		rpc("send_actual_data", Game._data_players, status)

func _paint_ready(id: int, color : Color) -> void:
	for child in players_list.get_children():
		if child.name == str(id):
			child.get_node("status").color = Color.GREEN

func _on_play_pressed() -> void:
	local_status = not local_status
	rpc("player_ready", local_status)
	_paint_ready(multiplayer.get_unique_id(), _get_color_status(local_status))
	option_button.disabled = true

func _character_changed(index: int) -> void:
	# Change the selected character and replicate the info to others players |		
	var id = multiplayer.get_unique_id()
	option_button.set_item_disabled(Game._data_players[id].character, false)
	Game._data_players[id].character = index
	option_button.set_item_disabled(index, true)
	players_list.get_node(str(id) + "/character").texture = Game.CHARACTER_PROFILES[index]
	rpc("send_data_players", id, Game._data_players[id])

func _level_changed(index: int) -> void:
	# Change the selected level and replicate the info to others players
	# This functions can only be called by the server side
	id_level = index
	level_path = options_levels_path[index]
	rpc("send_level_data", index)

@rpc("any_peer", "reliable")
func send_info(info: Dictionary) -> void:
	var id = multiplayer.get_remote_sender_id()
	_add_player(info.name, info.color_name, id)

@rpc("reliable", "any_peer", "call_local")
func player_ready(state: bool) -> void:
	var id = multiplayer.get_remote_sender_id()
	_paint_ready(id, _get_color_status(state))
	if multiplayer.is_server():
		status[id] = true
		var all_ok = true
		for ok in status.values():
			all_ok = all_ok and ok
		if all_ok:
			rpc("start_game", level_path)
	
@rpc("any_peer", "reliable")
func send_data_players(id: int, data: Dictionary) -> void:
	# Send the info of a single player to others when the local change character
	if Game._data_players.has(id):
		option_button.set_item_disabled(Game._data_players[id].character, false)
	Game._data_players[id] = data
	option_button.set_item_disabled(data.character, true)
	players_list.get_node(str(id) + "/character").texture = Game.CHARACTER_PROFILES[data.character]
	
@rpc("reliable")
func send_actual_data(data: Dictionary, status: Dictionary) -> void:
	# Get and synchronize the info between all the players when a new peer is connected
	Game._data_players = data
	print(players_list.get_node(str(1) + "/status"))
	for key in Game._data_players:
		var value = Game._data_players[key]
		if key == multiplayer.get_unique_id():
			option_button.select(value.character)
		option_button.set_item_disabled(value.character, true)
		if players_list.get_node(str(key) + "/character") != null:
			players_list.get_node(str(key) + "/character").texture = Game.CHARACTER_PROFILES[value.character]
	
	for key in status:
		if status[key] == true:
			players_list.get_node(str(key) + "/status").color = Color.GREEN

@rpc("any_peer", "reliable")
func send_level_data(index_level: int) -> void:
	level_path = options_levels_path[index_level]
	option_level.selected = index_level

@rpc("any_peer", "call_local", "reliable")
func start_game(path) -> void:
	# start game 
	get_tree().change_scene_to_file(path)
