extends Node

# Constants
const PORTALS_COLORS = {
	0 	: [Color(0.9, 0.1, 0.1), Color(0.9, 0.5, 0.5)],
	1 	: [Color(0.1, 0.1, 0.9), Color(0.5, 0.5, 0.9)],
	2 	: [Color(0.1, 0.9, 0.1), Color(0.5, 0.9, 0.5)],
	3 	: [Color(0.9, 0.9, 0.1), Color(1, 0.7, 0.1)],
	4 	: [Color(0.24, 0.04, 0), Color(0.5, 0.23, 0.16)],
	5 	: [Color(0.7, 0.43, 0), Color(0.96, 0.44, 0.13)],
	6 	: [Color(0.32, 0, 0.32), Color(0.52, 0, 0.76)],
	7	: [Color(0.93, 0.27, 0.84), Color(0.75, 0, 0.65)],
}

const CHARACTER_PROFILES ={
	0 : preload("res://assets/player/profile/red_profile.png"),
	1 : preload("res://assets/player/profile/blue_profile.png"),
	2 : preload("res://assets/player/profile/green_profile.png"),
	3 : preload("res://assets/player/profile/yellow_profile.png"),
	4 : preload("res://assets/player/profile/brown_profile.png"),
	5 : preload("res://assets/player/profile/orange_profile.png"),
	6 : preload("res://assets/player/profile/purple_profile.png"),
	7 : preload("res://assets/player/profile/pink_profile.png"),
}

const CHARACTER_NAME = {
	0 : "Red",
	1 : "Blue",
	2 : "Green",
	3 : "Yellow",
	4 : "Brown",
	5 : "Orange",
	6 : "Purple",
	7 : "Pink",
}

# Variables
var _players : Array = []
var _bullets : Array = []
var _name_players : Dictionary = {}
var _data_players : Dictionary = {}
var _death_players : int = 0
var _thread = null

var id_winner : String

signal upnp_completed(error)

const PORT = 5000

func _upnp_setup(server_port):
	# UPNP queries take some time.
	var upnp = UPNP.new()
	var err = upnp.discover()

	if err != OK:
		push_error(str(err))
		emit_signal("upnp_completed", err)
		return

	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "UDP")
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "TCP")
		emit_signal("upnp_completed", OK)

func _ready():
	_thread = Thread.new()
	_thread.start(_upnp_setup.bind(PORT))

func _exit_tree():
	# Wait for thread finish here to handle game exit while the thread is running.
	_thread.wait_to_finish()

func delete_data() -> void:
	_players = []
	_bullets = []
	_name_players = {}
	_data_players = {}
	_death_players = 0
