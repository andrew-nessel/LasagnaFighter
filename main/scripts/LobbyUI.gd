extends Node

@export var playerSlotObject : PackedScene
@export var playerSlotContainer : Control
@export var playerMatchObject : PackedScene
@export var playerMatchContainer : Control

var totalPlayerNumber = 2
var totalMatches = 1
var player_slots = []
var match_slots = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LobbyClient.player_connected.connect(update_player_slot)
	LobbyClient.player_disconnected.connect(update_player_slot2) #TODO fix these 2 so that they only update whats necessary and actually use the info sent....
	LobbyClient.server_connected.connect(ready_slots)
	LobbyClient.player_slot_change.connect(_change_player_slot)
	LobbyClient.player_slot_ready.connect(_player_slot_ready)
	ready_slots()
	pass 
	
func ready_slots() -> void:
	totalPlayerNumber = LobbyClient.get_total_player_number()
	totalMatches = max(1, floor(totalPlayerNumber/2.0))
	player_slots = []
	match_slots = []
	
	#Handle adding all the player slots
	for n in playerSlotContainer.get_children():
		playerSlotContainer.remove_child(n)
		n.queue_free()
	for x in range(totalPlayerNumber):
		var instance = playerSlotObject.instantiate()
		playerSlotContainer.add_child(instance)
		instance.set_label_text("")
		player_slots.append(instance)
		instance.pressed.connect(_on_player_slot_pressed.bind(x))
	
	#Handle adding all the match slots
	for n in playerMatchContainer.get_children():
		playerMatchContainer.remove_child(n)
		n.queue_free()
	for x in range(totalMatches):
		var instance = playerMatchObject.instantiate()
		playerMatchContainer.add_child(instance)
		match_slots.append(instance)
		instance.set_label_text("Match " + str(x+1))
		instance.get_player_slot(0).pressed.connect(_on_match_slot_pressed.bind(x,0))
		instance.get_player_slot(1).pressed.connect(_on_match_slot_pressed.bind(x,1))
		instance.get_player_slot(0).set_label_text("")
		instance.get_player_slot(1).set_label_text("")
		instance.get_ready_button().pressed.connect(on_ready_pressed.bind(x))
		instance.disable_ready_button()
	update_player_slots()

func update_player_slot(_player_id : int, _player_info : Dictionary) -> void:
	#print("playerid: " + str(player_id) + " player_info: " + str(player_info))
	#var ps
	#var slotN = LobbyClient.playerInfo(player_info).get_current_lobby_slot()
	#if(slotN < totalPlayerNumber):
		#ps = player_slots[slotN]
	#else:
		#ps = match_slots[floor((slotN - totalPlayerNumber)/2.0)].get_player_slot(slotN % 2)
	#ps.set_is_full(true)
	#ps.set_label_text(player_info.get_player_name())
	update_player_slots()
	return

func update_player_slot2(_player_id : int) -> void:
	#print("playerid: " + str(player_id) + " player_info: " + str(player_info))
	#var ps
	#var slotN = LobbyClient.playerInfo(player_info).get_current_lobby_slot()
	#if(slotN < totalPlayerNumber):
		#ps = player_slots[slotN]
	#else:
		#ps = match_slots[floor((slotN - totalPlayerNumber)/2.0)].get_player_slot(slotN % 2)
	#ps.set_is_full(true)
	#ps.set_label_text(player_info.get_player_name())
	update_player_slots()
	return

func update_player_slots() -> void:
	var pis = LobbyClient.get_all_player_info()
	clear_all_slots()
	for x in pis:
		#print(str(x) + " in player info")
		var ps
		var slotN = pis[x].get_current_lobby_slot()
		if(slotN < totalPlayerNumber):
			ps = player_slots[slotN]
		else:
			ps = match_slots[floor((slotN - totalPlayerNumber)/2.0)].get_player_slot(slotN % 2)
		ps.set_is_full(true)
		ps.set_label_text(pis[x].get_player_name())
	return
	
func clear_all_slots():
	for ps in player_slots:
		ps.set_label_text("")
		ps.set_is_full(false)
	for ps in match_slots:
		ps.get_player_slot(0).set_label_text("")
		ps.get_player_slot(0).set_is_full(false)
		ps.get_player_slot(1).set_label_text("")
		ps.get_player_slot(1).set_is_full(false)

func _on_disconnect_button_pressed() -> void:
	LobbyClient.disconnect_lobby()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	pass 


func set_total_player_number(number : int) -> void:
	totalPlayerNumber = number
	

func _on_player_slot_pressed(number : int) -> void:
	var ps = player_slots[number]
	#print("trying to get slot " + str(number))
	if(ps.get_is_full()):
		#print("that slot is ui full")
		return
	LobbyClient.request_lobby_player_slot_ui(number)
	pass
	

func _change_player_slot(number : int, player_id : int) -> void:
	if(number >= totalPlayerNumber):
		#print("number: " +str(number)+" match_number: " +str(floor((number - totalPlayerNumber)/2.0))+" slot_number: " +str(((number-totalPlayerNumber) % 2)))
		_change_player_match_slot(floor((number - totalPlayerNumber)/2.0), ((number-totalPlayerNumber) % 2), player_id)
		return
	var ps = player_slots[number]
	var pi = LobbyClient.get_player_info(player_id)
	ps.set_label_text(pi.get_player_name())
	ps.set_is_full(true)
	clear_previous_player_slot(pi.get_current_lobby_slot(), player_id)
	#pi.set_current_lobby_slot(number)
	LobbyClient.set_players_current_lobby_slot(player_id, number)
	pass

func _on_match_slot_pressed(match_number : int, slot_number : int) -> void:
	var ps = match_slots[match_number].get_player_slot(slot_number)
	if(ps.get_is_full()):
		#print("that slot is ui full")
		return
	#print("requesting + " + str((totalPlayerNumber-1) + (match_number*2) + (slot_number+1)))
	LobbyClient.request_lobby_player_slot_ui((totalPlayerNumber-1) + (match_number*2) + (slot_number+1))
	pass

func _change_player_match_slot(match_number : int, slot_number : int, player_id : int) -> void:
	#print("ui got here")
	var ps = match_slots[match_number].get_player_slot(slot_number)
	var pi = LobbyClient.get_player_info(player_id)
	#print("ui got here + " + pi.get_player_name() + " + match :" + str(match_number) + " + slot :" + str(slot_number))
	ps.set_label_text(pi.get_player_name())
	ps.set_is_full(true)
	match_slots[match_number].clear_all_ready()
	clear_previous_player_slot(pi.get_current_lobby_slot(), player_id)
	LobbyClient.set_players_current_lobby_slot(player_id, (totalPlayerNumber-1) + (match_number*2) + (slot_number+1))
	if(match_slots[match_number].get_is_full()):
		#print("match is full")
		var myid = LobbyClient.get_my_player_id()
		var myslot = LobbyClient.get_player_info(myid).get_current_lobby_slot()
		var my_match_number = floor((myslot - totalPlayerNumber)/2.0)
		#print("my match:" + str(my_match_number) + " their match:" + str(match_number) + " my slot:" + str(myslot) + " player number:" + str(totalPlayerNumber))
		if((myslot >= totalPlayerNumber) and (my_match_number == match_number)):
			match_slots[match_number].enable_ready_button()
	pass

func clear_previous_player_slot(number : int, _player_id : int) -> void:
	var ps 
	if(number < totalPlayerNumber):
		ps = player_slots[number]
	else:
		var match_number = floor((number - totalPlayerNumber)/2.0)
		ps = match_slots[match_number].get_player_slot((number-totalPlayerNumber) % 2)
		match_slots[match_number].clear_all_ready()
		match_slots[match_number].disable_ready_button()
	ps.set_label_text("")
	ps.set_is_full(false)
	pass
	
func on_ready_pressed(matchNumber : int) -> void:
	var slot_number = LobbyClient.get_player_info(LobbyClient.get_my_player_id()).get_current_lobby_slot()
	if(slot_number < totalPlayerNumber):
		print("trying to ready while not in a match slot")
		return
	var match_number = floor((slot_number - totalPlayerNumber)/2.0)
	if(match_number != matchNumber):
		print("trying to ready for the wrong match")
		return
	LobbyClient.request_lobby_player_ready_ui(slot_number)
	pass
	
func _player_slot_ready(slot_number : int, _player_id : int) -> void:
	if(slot_number < totalPlayerNumber):
		print("trying to ready while not in a match slot")
		return
	var match_number = floor((slot_number - totalPlayerNumber)/2.0)
	var snumber = ((slot_number-totalPlayerNumber) % 2)
	match_slots[match_number].set_slot_ready(snumber)
	#TODO rewrite this so that the lobby client has all the info it needs to know when two players are ready and who those two players are (this may not work if server host is in match...)
	if(match_slots[match_number].get_is_ready()):
		LobbyClient.match_is_ready(match_number)
	pass
