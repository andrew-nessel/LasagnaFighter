extends Node

signal start_match
signal opponenet_input

enum NetworkState {ERROR, IDLE, FIRSTCONTACT, MATCHINFO, WAITFORLOAD, WAITFORSTART, MATCHINPROGRESS, ROUNDOVER, WAITFORROUND, MATCHOVER} #network states
var socket = PacketPeerUDP.new()
var is_server = false
var is_listening = false
var mutex: Mutex
var listen_thread : Thread
var dest_port = ""
var dest_address = 0
var current_state = NetworkState.IDLE
var time_since_last_message = Time.get_ticks_msec()
var time_interval = 100 #100ms or 1/10 sec
var total_retries = 3
var current_retry = 0

#Ping management
var time_since_last_ping = Time.get_ticks_msec()
var ping_interval = 200 #300ms or 5 times per second
var ping_timestamp = Time.get_ticks_msec()
var last_ping = 0
var average_ping = 0 #last 3 pings
var ping_array = [-1,-1,-1,-1,-1] #this holds the last 5 ping tests so we can average current ping
var current_ping_index = 0

#Match Loading
var game_scene_ready = false
var opponent_game_scene_ready = false
const online_match_scene_path = "res://scenes/online_match.tscn"
var match_handler : OnlineMatchWrapper
#(online fighting game handler wraps fighting game and tells us when loaded)

#Match start timing info
var match_start_timing = 0 #hold the match start time we generated or the server sent us
var match_start_interval = 5000 #5000ms or 5 sec
var match_start_confirmed = false

#MatchInfo #TODO get these numbers from somewhere
var frameDelay = 0
var roundsNumber = 3
var characterID = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mutex = Mutex.new()
	listen_thread = Thread.new()
	pass # Replace with function body.
	

func _exit_tree() -> void:
	stop_network()

func stop_network() -> void:
	mutex.lock()
	is_listening = false
	mutex.unlock()
	listen_thread.wait_to_finish()
	socket.close()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	match current_state:
		NetworkState.IDLE:
			pass
		NetworkState.FIRSTCONTACT:
			#if(is_server):
			send_connect_message()
			pass
		NetworkState.MATCHINFO:
			send_match_info_message(frameDelay, roundsNumber, characterID) 
			pass
		NetworkState.WAITFORSTART:
			if(!match_start_confirmed):
				var start_time = getMatchStartTime()
				send_start_message(start_time, 0) #this is the start of a match so 0
			if((Time.get_ticks_msec() >= match_start_timing) && (match_start_timing > 0)):
				match_start_timing = -1
				print("Match actually started")
				start_match.emit()
			pass
		NetworkState.ERROR:
			print("Network state broken")
			send_error_message(0, true)
			stop_network()
			pass
		_:
			pass
	
	if(current_state != NetworkState.IDLE): #TODO this is to stop it from sending ping messages before connecting, we should fix this to have some we have connected/are still connected check...
		if((Time.get_ticks_msec() - time_since_last_ping)> ping_interval):
			send_ping(true)
	pass

func start_client(server : bool, myport: int, address : String, port : int) -> void:
	socket = PacketPeerUDP.new()
	is_server = server
	dest_address = address
	dest_port = port
	
	var error = socket.bind(myport)
	if error != OK:
		printerr("Failed to bind socket: " + error_string(error))
		socket.close()
		return
	
	error = socket.connect_to_host(address, port)
	if error != OK:
		printerr("Failed to connect to host: " + error_string(error))
		socket.close()
		return
		
	mutex.lock()
	is_listening = true
	if(is_server): #the server starts ahead in network state and the client responds as it follows
		current_state = NetworkState.FIRSTCONTACT
	mutex.unlock()
	listen_thread = Thread.new()
	listen_thread.start(listen_loop)
	pass
	

#{ERROR, CONNECT, DISCONNECT, MATCHINFO, STARTMESSAGE, FRAMEDATAINPUT}
func send_error_message(code : int, dis : bool) -> void:
	var c_time = Time.get_ticks_msec()
	if((c_time - time_since_last_message) > time_interval):
		time_since_last_message = c_time 
		var message = NetworkMessage.new()
		message.createErrorMessage(code, dis)
		socket.put_packet(message.pArray)
		print("sent connect message")
	pass
	
func send_connect_message() -> void:
	if(!is_server):
		if(current_retry>=total_retries):
			return
		current_retry+=1
	var c_time = Time.get_ticks_msec()
	if((c_time - time_since_last_message) > time_interval):
		time_since_last_message = c_time 
		var message = NetworkMessage.new()
		message.createConnectMessage()
		socket.put_packet(message.pArray)
		print("sent connect message")
	pass
	
func send_disconnect_message() -> void:
	var c_time = Time.get_ticks_msec()
	if((c_time - time_since_last_message) > time_interval):
		time_since_last_message = c_time 
		var message = NetworkMessage.new()
		message.createDisconnectMessage()
		socket.put_packet(message.pArray)
		print("sent disconnect message")
	pass
	
func send_match_info_message(fDelay : int, roundsNum : int, cID : int) -> void:
	if(!is_server): 
		if(current_retry>=total_retries):
			print("we hit match info retry limit")
			mutex.lock()
			current_state = NetworkState.WAITFORLOAD
			mutex.unlock()
			begin_loading.call_deferred()
			return
		current_retry+=1
	var c_time = Time.get_ticks_msec()
	if((c_time - time_since_last_message) > time_interval):
		time_since_last_message = c_time 
		var message = NetworkMessage.new()
		message.createMatchInfoMessage(fDelay, roundsNum, cID, Time.get_ticks_msec())
		socket.put_packet(message.pArray)
		print("sent match info message")
	pass
	
func send_start_message(startTiming : int, startType : int) -> void:
	if(!is_server): 
		if(current_retry>=total_retries):
			return
		current_retry+=1
	var c_time = Time.get_ticks_msec()
	if((c_time - time_since_last_message) > time_interval):
		time_since_last_message = c_time 
		var message = NetworkMessage.new()
		message.createStartMessage(startTiming, startType)
		socket.put_packet(message.pArray)
		print("sent start message")
	pass
	
func send_frame_data_message(input : InputHolder, timing : int) -> void:
	var c_time = Time.get_ticks_msec()
	if((c_time - time_since_last_message) > time_interval): #TODO this probably shouldn't be checking this timing info or it should have a seperate more leninet timing 
		time_since_last_message = c_time 
		var message = NetworkMessage.new()
		message.createFrameDataMessage(input, timing)
		socket.put_packet(message.pArray)
		print("sent frame data message")
	pass

func send_ping(origin : bool):
	if(origin):
		ping_timestamp = Time.get_ticks_msec()
		time_since_last_ping = Time.get_ticks_msec()
	var message = NetworkMessage.new()
	message.createPingMessage(origin)
	socket.put_packet(message.pArray)
	print("sent ping message")
	return
	

func send_load_complete_message():
	var message = NetworkMessage.new()
	message.createLoadCompleteMessage()
	socket.put_packet(message.pArray)
	print("sent load complete message")
	return

func listen_loop() -> void: #TODO change this to a concurrent process that adds new packets to a queue with worker threads that pulls packets from that queue and process them
	while is_listening:
		if(socket.get_available_packet_count() > 0):
			processPacket(socket.get_packet())
			

func processPacket(packet : PackedByteArray) -> void:
	var message = NetworkMessage.new()
	message.decodePacket(packet)
	match message.mtype:
		NetworkMessage.MessageType.ERROR:
			handleErrorMessage(message)
			pass
		NetworkMessage.MessageType.CONNECT:
			handleConnectMessage(message)
			pass
		NetworkMessage.MessageType.DISCONNECT:
			print("Received disconnect packet")
			stop_network()
			pass
		NetworkMessage.MessageType.MATCHINFO:
			handleMatchInfoMessage(message)
			pass
		NetworkMessage.MessageType.STARTMESSAGE:
			handleStartMessage(message)
			pass
		NetworkMessage.MessageType.FRAMEDATAINPUT:
			handleFrameDataMessage(message)
			pass
		NetworkMessage.MessageType.PING:
			handle_ping_message(message)
			pass
		NetworkMessage.MessageType.LOADCOMPLETE:
			handle_load_complete_message(message)
			pass
		_:
			print("Message type not found, was this a decoding error?")
			pass


func handleErrorMessage(message : NetworkMessage):
	print("We received an error packet...")
	if(message.errorMessageHolder.causeDisconnect):
		socket.close()
		print("Error packet requested disconnect")
	
func handleConnectMessage(message : NetworkMessage):
	print("recieved connect message")
	if(message.mtype != NetworkMessage.MessageType.CONNECT):
		return
	match current_state:
		NetworkState.FIRSTCONTACT:
			if(is_server):
				mutex.lock()
				current_state = NetworkState.MATCHINFO
				mutex.unlock()
		NetworkState.IDLE:
			if(!is_server):
				mutex.lock()
				current_state = NetworkState.FIRSTCONTACT
				current_retry = 0
				mutex.unlock()
		_:
			pass
	return
	
func handleMatchInfoMessage(message : NetworkMessage):
	print("recieved match info message")
	if(!is_server): #overwrites the clients decision with the servers info
		frameDelay = message.matchInfoHolder.frameDelay
		roundsNumber = message.matchInfoHolder.roundsNumber
	else:
		if(frameDelay != message.matchInfoHolder.frameDelay):
			print("The client sent different frame delay then us...")
		if(roundsNumber != message.matchInfoHolder.roundsNumber):
			print("The client sent different rounds number then us...")
		
	match current_state:
		NetworkState.MATCHINFO:
			if(is_server):
				mutex.lock()
				match_start_confirmed = false
				current_state = NetworkState.WAITFORLOAD
				mutex.unlock()
				begin_loading.call_deferred()
		NetworkState.FIRSTCONTACT:
			if(!is_server):
				mutex.lock()
				match_start_confirmed = false
				current_state = NetworkState.MATCHINFO
				current_retry = 0
				mutex.unlock()
				
	return
	
func handleStartMessage(message : NetworkMessage):
	print("recieved start message")
	match message.startMessageHolder.startType:
		0: #this is a match
			if(is_server):
				mutex.lock()
				match_start_confirmed = true
				mutex.unlock()
				if(match_start_timing != message.startMessageHolder.startTiming):
					print("We recieved a start time different from our own: ours - " + str(match_start_timing) +  " theirs - " + str(message.startMessageHolder.startTiming))
			else:
				mutex.lock()
				match_start_timing = message.startMessageHolder.startTiming
				current_state = NetworkState.WAITFORSTART
				current_retry = 0
				mutex.unlock()
			pass
		1: #this is a round
			pass
		_: #this is nothing error I guess
			print("Start message has invalid start type")
			pass
	return
	
func handleFrameDataMessage(message : NetworkMessage):
	print("recieved frame data message")
	if(message.mtype != NetworkMessage.MessageType.FRAMEDATAINPUT):
		return
	send_opponent_input.call_deferred(message.frameDataHolder.input, message.frameDataHolder.timing)
	return
	
func getMatchStartTime() -> int:
	var stime
	if(is_server):
		stime = Time.get_ticks_msec() + match_start_interval
		match_start_timing = stime
	else:
		stime = match_start_timing
	return stime


func handle_ping_message(message : NetworkMessage):
	
	if(message.pingMessageHolder.pingOrigin == 1): #we sent this request to them originally 
		var ping = Time.get_ticks_msec() - ping_timestamp
		if(current_ping_index >= ping_array.size()):
			current_ping_index = 0
		last_ping = ping
		ping_array[current_ping_index] = ping
		current_ping_index+=1
		calculate_average_ping()
		print("recieved ping message" + str(ping))
	else: #they sent us a ping request so just send a reply
		send_ping(false)
		print("recieved ping message")
	return
	

func handle_load_complete_message(message : NetworkMessage):
	print("recieved load complete message")
	if(message.mtype != NetworkMessage.MessageType.LOADCOMPLETE):
		return
	mutex.lock()
	opponent_game_scene_ready = true
	mutex.unlock()
	match current_state:
		NetworkState.WAITFORLOAD:
			if(is_server):
				mutex.lock()
				current_state = NetworkState.WAITFORSTART
				mutex.unlock()
		NetworkState.MATCHINFO:
			if(!is_server):
				mutex.lock()
				current_state = NetworkState.WAITFORLOAD
				current_retry = 0
				mutex.unlock()
				begin_loading.call_deferred()
		_:
			pass
	return
	

func calculate_average_ping():
	var avr = 0
	for i in ping_array:
		if(i == -1):
			average_ping = ping_array[0]
			return
		avr += i
	average_ping = int(floor(avr/ping_array.size()))
	print("current average ping is " + str(average_ping))
	return

func match_has_loaded() -> void:
	game_scene_ready = true
	send_load_complete_message()
	match_handler = get_tree().root.get_script() 
	return
	
func begin_loading() -> void:
	if(!game_scene_ready):
		get_tree().change_scene_to_file(online_match_scene_path)
		
func get_is_player_one() -> bool:
	return is_server
	

func send_opponent_input(input : InputHolder, timing : int) -> void:
	emit_signal("opponenet_input", input, timing)

#func start_match() -> void:
	#if(game_scene_ready and opponent_game_scene_ready):
		#match_handler.start_match()

#TODO 
# handle actually waiting for the round to start, 
#making sure the client sends only enough waitforstart messages (or server ignores them??) (retry number handling?), 
#handle opening the match up, handle round being over (we dont send the round amount of time, 
#does this need to be added to matchinfo?), handle coordinating round start, handle coordinating when match is over (best of 2 scenario, or all 3 rounds), 
#handling disconnect after (how do we handle rematchs), 
#handling resetting all the nonsense that went on so we can match with a different person, 
#handle sending actaully frame input data

#time dilemma - match info has a current time stamp (which is in time since ticked) which you can use to subtract from our current time ticked so you get an offset,
#then all start or timing messages have current time ticked when message was sent which you can use the first time stamp offset and the new timing offset to calculate the relative timing info...
#we will have to include a ping response message to get relative ping timing to add that to the pile... 

#Fix the ping to be one way ping and correctly display with correct units
