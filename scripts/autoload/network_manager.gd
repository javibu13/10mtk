extends Node

const PORT = 9999
const MAX_PLAYERS = 4

var peer : ENetMultiplayerPeer
var is_server_mode : bool = false

signal server_created
signal server_creation_failed
signal connected_to_server
signal connection_failed
signal player_connected(id)
signal player_disconnected(id)


func create_server():
	# Signal connection
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(PORT, MAX_PLAYERS)
	
	if result != OK:
		print("Error at server creation: ", result)
		server_creation_failed.emit()
		return false
	
	multiplayer.multiplayer_peer = peer
	is_server_mode = true
	
	print("Server created at port: ", PORT)
	server_created.emit()
	return true


func create_client(ip: String = "127.0.0.1"):
	# Signal connection
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_client(ip, PORT)
	
	if result != OK:
		print("Error at server connection: ", result)
		connection_failed.emit()
		return false
	
	multiplayer.multiplayer_peer = peer
	is_server_mode = false
	
	print("Trying to connect to: ", ip, ":", PORT)
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
