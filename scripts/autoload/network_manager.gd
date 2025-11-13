extends Node

signal server_created
signal server_creation_failed
signal connected_to_server
signal connection_failed
signal player_connected(id)
signal player_disconnected(id)
signal server_print_msg(msg)


var ip_address := "127.0.0.1"
var port := 2828
var max_players := 64
var peer: ENetMultiplayerPeer
var is_server_mode := false


func _ready():
	# Get command line arguments
	var args: Array = OS.get_cmdline_args()
	if "--server" in args:
		print("Starting as SERVER")
		if "--port" in args:
			var port_index: int = args.find("--port")
			port = args.get(port_index + 1).to_int()
		if "--maxplayers" in args:
			var max_players_index: int = args.find("--maxplayers")
			max_players = args.get(max_players_index + 1).to_int()
		DatabaseManager.initialize_server_database()
		get_tree().change_scene_to_file.call_deferred("res://scenes/Server.tscn")
		await get_tree().create_timer(1.0).timeout  # Wait for server scene load
		create_server()
		return
	if "--client" in args:
		print("Starting as CLIENT")
		if "--port" in args:
			var port_index: int = args.find("--port")
			port = args.get(port_index + 1).to_int()
		if "--ip" in args:
			var ip_index: int = args.find("--ip")
			ip_address = args.get(ip_index + 1)
		await get_tree().create_timer(1.0).timeout  # Wait for server launch
		create_client()
		return


func create_server():
	# Signal connection
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	# Create server
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(port, max_players)
	# Check server creation
	if result != OK:
		print("Error at server creation: ", result)
		server_print_msg.emit("Error at server creation: " + str(result))
		server_creation_failed.emit()
		return false
	# Assign peer
	multiplayer.multiplayer_peer = peer
	is_server_mode = true
	# Notify server creation
	print("Server created at port: ", port)
	server_print_msg.emit("Server created at port: " + str(port))
	server_created.emit()
	return true


func create_client():
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
		multiplayer.connection_failed.emit()
		return false
	# Assign peer
	multiplayer.multiplayer_peer = peer
	is_server_mode = false
	# Notify client connection
	print("Trying to connect to: ", ip_address, ":", port)
	return true


func _on_peer_connected(id):
	print("Player connected: ", id)
	server_print_msg.emit("Player connected: " + str(id))
	player_connected.emit(id)


func _on_peer_disconnected(id):
	print("Player disconnected: ", id)
	server_print_msg.emit("Player disconnected: " + str(id))
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
