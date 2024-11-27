extends Node

const ADDRESS = "127.0.0.1"
const PORT = 9999

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var packet = PacketPeerUDP.new()
	packet.connect_to_host(ADDRESS, PORT)
	packet.put_var("HI")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
