extends Node

const PORT = 9999
const MAX_PLAYERS = 2
var server = UDPServer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	server.listen(PORT)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	server.poll()
	if server.is_connection_available():
		var peer = server.take_connection()
		var message = peer.get_var()
		print(message)
	pass
	
