extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
#signal server_disconnected
signal server_connected
signal player_slot_change(slot_number, peer_id)
signal player_slot_ready(slot_number, peer_id)

var peer = ENetMultiplayerPeer.new()
var is_server = false
var totalPlayerNumber = 0
var currentPlayerCount = 1
var player_info_list = {}
var lobby_slots = {}
var slotMax = 0
var rng = RandomNumberGenerator.new()

class playerInfo:
	var player_name : String
	var current_lobby_slot : int
	var connection_address : String
	var connection_port : int
	
	func create_from_object(ob : Dictionary) -> void:
		player_name = ob["name"]
		current_lobby_slot = ob["seat"]
		connection_address = ob["address"]
		connection_port = ob["port"]
	func to_object() -> Dictionary:
		var ob = {}
		ob["name"] = player_name
		ob["seat"] = current_lobby_slot
		ob["address"] = connection_address
		ob["port"] = connection_port
		return ob
	func set_player_name(name : String) -> void:
		player_name = name
	func get_player_name() -> String:
		return player_name
	func set_current_lobby_slot(slot_number : int) -> void:
		current_lobby_slot = slot_number
	func get_current_lobby_slot() -> int:
		return current_lobby_slot
	func set_connection_address(address : String) -> void:
		connection_address = address
	func get_connection_address() -> String:
		return connection_address
	func set_connection_port(port : int) -> void:
		connection_port = port
	func get_connection_port() -> int:
		return connection_port

var my_player_info = playerInfo.new() 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func start_lobby_server(port) -> void:
	is_server = true
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	player_info_list[1] = my_player_info
	player_connected.emit(1, my_player_info)
	slotMax = totalPlayerNumber + (max(1, floor(totalPlayerNumber/2.0)) * 2)
	for i in range(slotMax):
		lobby_slots[i] = -1
	lobby_slots[0] = 1
	

func start_lobby_client(address, port) -> void:
	is_server = false
	peer.create_client(address, int(port))
	multiplayer.multiplayer_peer = peer
	

func disconnect_lobby() -> void:
	multiplayer.multiplayer_peer = null
	peer = ENetMultiplayerPeer.new()
	my_player_info = playerInfo.new()
	is_server = false
	totalPlayerNumber = 0
	currentPlayerCount = 1
	player_info_list = {}
	lobby_slots = {}
	slotMax = 0
	

func _on_player_connected(id) -> void:
	print("peer connected: " + str(id))
	return
	
func assign_seat(id : int) -> void:
	var cslot = 0
	var ok = true
	for i in range(totalPlayerNumber):
		ok = true
		for x in player_info_list:
			if player_info_list[x].get_current_lobby_slot() == cslot:
				print("lobby slot " + str(i) + " is occupied by " + str(player_info_list[x].get_player_name()))
				ok = false
		if !ok:
			cslot+=1
		else:
			break
	if ok:
		player_info_list[id].set_current_lobby_slot(cslot)
		lobby_slots[cslot] = id
	else:
		print("couldn't find a seat for peer " + str(id) + " - is lobby full?")
	pass

@rpc("authority", "call_remote", "reliable")
func _server_info(s_info):
	totalPlayerNumber = s_info["total_players"]
	slotMax = totalPlayerNumber + (max(1, floor(totalPlayerNumber/2.0)) * 2)
	for i in range(slotMax):
		lobby_slots[i] = -1
	update_player_info_from_object(s_info["player_info_list"])
	server_connected.emit()
	return
	
func update_player_info_from_object(obj : Dictionary):
	var pil = {} 
	for x in obj:
		var pi = playerInfo.new()
		pi.create_from_object(obj[x])
		pil[x] = pi
		lobby_slots[pi.get_current_lobby_slot()] = x
	player_info_list = pil
	pass

func return_player_info_list_as_object() -> Dictionary:
	var pil = {}
	for x in player_info_list:
		pil[x] = player_info_list[x].to_object()
	return pil
	

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	if is_server:
		var new_player_id = multiplayer.get_remote_sender_id()
		if currentPlayerCount >= totalPlayerNumber:
			print("server full")
			get_out_of_here_idiot.rpc_id(new_player_id)
			return
		currentPlayerCount+=1
		var npi = playerInfo.new()
		npi.create_from_object(new_player_info)
		npi.set_current_lobby_slot(-1)
		player_info_list[new_player_id] = npi
		assign_seat(new_player_id)
		#player_info_list[new_player_id] = npi
		player_connected.emit(new_player_id, new_player_info)
		_server_info.rpc({"total_players":totalPlayerNumber, "player_info_list":return_player_info_list_as_object()})
		#player_connected.emit(new_player_id)
	return

func _on_player_disconnected(id) -> void:
	print("peer disconnected: " + str(id))
	#TODO Deregister player from server and propigate that info
	if is_server and player_info_list.has(id):
		currentPlayerCount-=1
		lobby_slots[player_info_list[id].get_current_lobby_slot()] = -1
		player_info_list.erase(id)
		_server_info.rpc({"total_players":totalPlayerNumber, "player_info_list":return_player_info_list_as_object()})
		player_disconnected.emit(id)
	pass

func _on_connected_ok() -> void:
	print("connected to server")
	var peer_id = multiplayer.get_unique_id()
	player_info_list[peer_id] = my_player_info
	_register_player.rpc_id(1, my_player_info.to_object())
	#player_connected.emit(peer_id, my_player_info.to_object())
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")
	pass

func _on_connected_fail() -> void:
	multiplayer.multiplayer_peer = null
	peer = ENetMultiplayerPeer.new()
	print("failed to connect to server")
	pass

func _on_server_disconnected() -> void:
	disconnect_from_lobby()
	pass
	
func disconnect_from_lobby() -> void:
	multiplayer.multiplayer_peer = null
	peer = ENetMultiplayerPeer.new()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	print("disconnected from server")
	my_player_info = playerInfo.new()
	is_server = false
	totalPlayerNumber = 0
	currentPlayerCount = 1
	player_info_list = {}
	lobby_slots = {}
	slotMax = 0
	pass
	
func set_total_player_number(number : int) -> void:
	totalPlayerNumber = number
	
func get_total_player_number() -> int:
	return totalPlayerNumber
	
func get_player_info(i : int) -> playerInfo:
	return player_info_list[i]

func set_player_name(pname : String):
	my_player_info.set_player_name(pname)
	
func set_player_address(address : String):
	my_player_info.set_connection_address(address)

func set_player_port(port : int):
	my_player_info.set_connection_port(port)

func get_all_player_info() -> Dictionary:
	return player_info_list

func set_players_current_lobby_slot(player_id : int, number : int):
	player_info_list[player_id].set_current_lobby_slot(number)
	
func get_my_player_id() -> int:
	return multiplayer.get_unique_id()

func request_lobby_player_slot_ui(slotNumber : int):
	if is_server:
		request_lobby_player_slot(slotNumber)
	else:
		request_lobby_player_slot.rpc_id(1, slotNumber)

@rpc("any_peer", "reliable")
func request_lobby_player_slot(slotNumber : int):
	if is_server:
		if lobby_slots[slotNumber] > -1:
			#print("that slot is multiplayer full")
			pass
		else:
			var player_id = multiplayer.get_remote_sender_id()
			if player_id == 0: #if the server is calling locally it won't have a sender id
				#print("this was the server requesting")
				player_id = 1
			#else:
				#print("this was " + str(player_id) + " requesting")
			lobby_slots[slotNumber] = player_id
			var cSlot = player_info_list[player_id].get_current_lobby_slot()
			lobby_slots[cSlot] = -1
			change_lobby_player_slot.rpc(slotNumber, player_id)
			player_slot_change.emit(slotNumber, player_id)
	pass

@rpc("authority", "call_remote", "reliable")
func change_lobby_player_slot(slotNumber : int, player_id : int):
	player_slot_change.emit(slotNumber, player_id)
	pass

@rpc("authority", "call_remote", "reliable")
func get_out_of_here_idiot():
	disconnect_from_lobby()
	pass

func request_lobby_player_ready_ui(slotNumber : int):
	if is_server:
		request_lobby_player_ready(slotNumber)
	else:
		request_lobby_player_ready.rpc_id(1, slotNumber)

@rpc("any_peer", "reliable")
func request_lobby_player_ready(slotNumber : int):
	if is_server:
		if lobby_slots[slotNumber] == -1:
			print("that slot isnt full but trying to ready")
			pass
		else:
			var player_id = multiplayer.get_remote_sender_id()
			if player_id == 0: #if the server is calling locally it won't have a sender id
				player_id = 1
			ready_lobby_player_slot.rpc(slotNumber, player_id)
			player_slot_ready.emit(slotNumber, player_id)
	pass

@rpc("authority", "call_remote", "reliable")
func ready_lobby_player_slot(slotNumber : int, player_id : int):
	player_slot_ready.emit(slotNumber, player_id)
	pass
	

func match_is_ready(match_number : int):
	if is_server:
		var slot1 = totalPlayerNumber + (match_number * 2)
		var slot2 = slot1+1
		var pid1 = lobby_slots[slot1]
		var pid2 = lobby_slots[slot2]
		
		var host = pid1
		var client = pid2
		#randomly pick a player to be host (should we check ping or always have the first slot as host?)
		#if rng.randf() > .5:
			#host = pid2
			#client = pid1
		
		start_match.rpc_id(host, true, player_info_list[host].get_connection_port(), player_info_list[client].get_connection_address(), player_info_list[client].get_connection_port())
		start_match.rpc_id(client, false, player_info_list[client].get_connection_port(), player_info_list[host].get_connection_address(), player_info_list[host].get_connection_port())
	pass

@rpc("authority", "call_local", "reliable")
func start_match(server : bool, myport: int, address : String, port : int):
	NetworkHandler.start_client(server, myport, address, port)
	pass
