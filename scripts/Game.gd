extends Node

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
