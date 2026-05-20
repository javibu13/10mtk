extends Node

signal server_created
signal server_creation_failed
signal static_ip_retrieved
signal connected_to_server
signal connection_failed
signal player_connected(id)
signal player_disconnected(id)
signal server_print_msg(msg)


var ip_address := "127.0.0.1"
var port := 28918
var max_players := 64
var peer: ENetMultiplayerPeer
var is_server_mode := false
var client_connected := false


func _ready():
	# Get command line arguments
	var args: Array = OS.get_cmdline_args()
	if "--server" in args:
		Log.pr("Starting as SERVER")
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
		get_tree().change_scene_to_file.call_deferred("res://scenes/LoginMenu.tscn")
		Log.pr("Starting as CLIENT")
		if "--port" in args:
			var port_index: int = args.find("--port")
			port = args.get(port_index + 1).to_int()
		if "--ip" in args:
			var ip_index: int = args.find("--ip")
			ip_address = args.get(ip_index + 1)
		else:
			request_static_ip()
			await static_ip_retrieved
		await get_tree().create_timer(1.0).timeout  # Wait for server launch
		create_client()
		return


func create_server():
	Log.set_colors_termsafe()
	# Signal connection
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	# Create server
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(port, max_players)
	# Check server creation
	if result != OK:
		#Log.pr("Error at server creation: ", result)
		server_print_msg.emit("Error at server creation: " + str(result))
		server_creation_failed.emit()
		return false
	# Assign peer
	multiplayer.multiplayer_peer = peer
	is_server_mode = true
	# Notify server creation
	Log.pr("Server created at port: ", port)
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
		Log.pr("Error at server connection: ", result)
		multiplayer.connection_failed.emit()
		return false
	# Assign peer
	multiplayer.multiplayer_peer = peer
	is_server_mode = false
	# Change timeout values
	peer.host.service(0)
	var enet_peer = peer.get_peer(1)
	enet_peer.set_timeout(0, 30000, 30000)
	# Notify client connection
	Log.pr("Trying to connect to: ", ip_address, ":", port)
	return true


func _on_peer_connected(id):
	#Log.pr("Player connected: ", id)
	server_print_msg.emit("Player connected: " + str(id))
	player_connected.emit(id)
	var enet_peer: ENetPacketPeer = multiplayer.multiplayer_peer.get_peer(id)
	enet_peer.set_timeout(0, 30000, 30000)


func _on_peer_disconnected(id):
	#Log.pr("Player disconnected: ", id)
	server_print_msg.emit("Player disconnected: " + str(id))
	player_disconnected.emit(id)


func _on_connected_to_server():
	Log.pr("Connected to server!")
	client_connected = true
	connected_to_server.emit()


func _on_connection_failed():
	Log.pr("Failed connection")
	connection_failed.emit()


func _on_server_disconnected():
	Log.pr("Server disconnected")


func disconnect_peer():
	if peer:
		peer.close()
		multiplayer.multiplayer_peer = null


func request_static_ip() -> void:
	var httpRequest: HTTPRequest = HTTPRequest.new()
	add_child(httpRequest)
	httpRequest.request_completed.connect(_on_http_request_completed)
	httpRequest.request("https://t.me/s/StaticJaMonGodot")


@warning_ignore("unused_parameter")
func _on_http_request_completed(result, response_code, headers, body) -> void:
	if response_code == 200:
		var html: String = body.get_string_from_utf8()
		var search_string = "SERVER_IP:"
		var pos = html.find(search_string)
		if pos != -1:
			var start = pos + search_string.length()
			var end = html.find("</div>", start)
			var a_element = html.substr(start, end - start).strip_edges()
			# IP Address is recognised by telegram as a link and it is formated as an "a" html tag
			var start_ip = a_element.find(">")
			var end_ip = a_element.find("</")
			var static_ip = a_element.substr(start_ip+1, end_ip - start_ip - 1).strip_edges()
			Log.info("Retrieved public static IP: ", static_ip)
			ip_address = static_ip
		else:
			Log.error("Public static IP not found in telegram message")
			ip_address = ""
	else:
		Log.error("Error trying to connect with telegram: ", response_code)
		ip_address = ""
	static_ip_retrieved.emit()
