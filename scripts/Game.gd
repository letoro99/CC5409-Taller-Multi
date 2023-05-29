extends Node

# Constants
const PORTALS_COLORS = {
	0 	: [Color(0.9, 0.1, 0.1), Color(0.9, 0.5, 0.5)],
	1 	: [Color(0.1, 0.1, 0.9), Color(0.5, 0.5, 0.9)],
	2 	: [Color(0.1, 0.9, 0.1), Color(0.5, 0.9, 0.5)],
	3 	: [Color(0.9, 0.9, 0.1), Color(1, 0.7, 0.1)],
	4 	: [Color(0.9, 0.9, 0.1), Color(1, 0.7, 0.1)],
	5 	: [Color(0.9, 0.9, 0.1), Color(1, 0.7, 0.1)],
	6 	: [Color(0.9, 0.9, 0.1), Color(1, 0.7, 0.1)],
	7 	: [Color(0.9, 0.9, 0.1), Color(1, 0.7, 0.1)],
}

# Variables
var _players : Array = []
var _bullets : Array = []
var _data_players : Dictionary = {}
var _thread = null

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
