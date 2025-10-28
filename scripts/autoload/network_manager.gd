extends Node

signal server_created
signal server_creation_failed
signal connected_to_server
signal connection_failed
signal player_connected(id)
signal player_disconnected(id)

const IP_ADDRESS := "127.0.0.1"
const PORT := 9999
const MAX_PLAYERS := 64

var peer: ENetMultiplayerPeer
var is_server_mode := false


func _ready():
	# Get command line arguments
	var args: Array = OS.get_cmdline_args()
	if "--server" in args:
		print("Starting as SERVER")
		var port := PORT
		if "--port" in args:
			var port_index: int = args.find("--port")
			port = args.get(port_index + 1).to_int()
		var max_players := MAX_PLAYERS
		if "--maxplayers" in args:
			var max_players_index: int = args.find("--maxplayers")
			max_players = args.get(max_players_index + 1).to_int()
		create_server(port, max_players)
		get_tree().change_scene_to_file.call_deferred("res://scenes/Server.tscn")
		return
	if "--client" in args:
		print("Starting as CLIENT")
		var port := PORT
		if "--port" in args:
			var port_index: int = args.find("--port")
			port = args.get(port_index + 1).to_int()
		var ip_address := IP_ADDRESS
		if "--ip" in args:
			var ip_index: int = args.find("--ip")
			ip_address = args.get(ip_index + 1)
		await get_tree().create_timer(1.0).timeout  # Wait for server launch
		create_client(ip_address, port)
		return


func create_server(port: int = PORT, max_players: int = MAX_PLAYERS):
	# Signal connection
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	# Create server
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(port, max_players)
	# Check server creation
	if result != OK:
		print("Error at server creation: ", result)
		server_creation_failed.emit()
		return false
	# Assign peer
	multiplayer.multiplayer_peer = peer
	is_server_mode = true
	# Notify server creation
	print("Server created at port: ", PORT)
	server_created.emit()
	return true


func create_client(ip_address: String = IP_ADDRESS, port: int = PORT):
	# Signal connection
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	# Create client
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_client(ip_address, port)
	# Check client creation
	if result != OK:
		print("Error at server connection: ", result)
		connection_failed.emit()
		return false
	# Assign peer
	multiplayer.multiplayer_peer = peer
	is_server_mode = false
	# Notify client connection
	print("Trying to connect to: ", ip_address, ":", port)
	return true


func _on_peer_connected(id):
	print("Player connected: ", id)
	player_connected.emit(id)


func _on_peer_disconnected(id):
	print("Player disconnected: ", id)
	player_disconnected.emit(id)


func _on_connected_to_server():
	print("Connected to server!")
	connected_to_server.emit()


func _on_connection_failed():
	print("Failed connection")
	connection_failed.emit()


func _on_server_disconnected():
	print("Server disconnected")


func disconnect_peer():
	if peer:
		peer.close()
		multiplayer.multiplayer_peer = null
