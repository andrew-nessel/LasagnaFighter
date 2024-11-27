extends Node

var socket = PacketPeerUDP.new()
var is_server = false
var is_listening = false
var mutex: Mutex
var listen_thread : Thread
var dest_port = ""
var dest_address = 0

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
#func _process(delta: float) -> void:
	#pass

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
	mutex.unlock()
	listen_thread = Thread.new()
	listen_thread.start(listen_loop)
	
	if(server):
		send_start_message()
	
	pass
	

func send_start_message() -> void:
	#THIS IS A RACE CONDITION (SEND UNTIL WE GET A RESPONSE AND THEN MOVE ONTO REAL SHIT)
	#socket.set_dest_address(dest_address, dest_port)
	socket.put_packet("start_match".to_ascii_buffer())
	print("sent message")
	pass
	

func listen_loop() -> void:
	while is_listening:
		if(socket.get_available_packet_count() > 0):
			var data = socket.get_packet().get_string_from_ascii()
			if data == "start_match":
				print("we started bitches")
				return
		
