extends Node

@export var netcode : RollbackNetwork
@export var clientPort : TextEdit
@export var clientAddress : TextEdit
@export var message : TextEdit
@export var serverPort : RichTextLabel
@export var serverAddress : RichTextLabel
var isLANConnection : bool


func _ready():
	return

func _process(delta):
	return


func _on_rollback_network_client_closed(success, error):
	print("client was closed: " + str(success) + ", error: " + error)

func _on_rollback_network_client_started(success, error):
	print("client was started: " + str(success) + ", error: " + error)
	serverAddress.text = "server address: " + netcode.get_server_address() + " (external: " + netcode.get_external_address() + ")"
	serverPort.text = "server port: " + str(netcode.get_server_port())

func _on_rollback_network_error(error):
	print("error: " + error)

func _on_rollback_network_message_received(msg, info):
	print("message was received: " + msg + ", msg info: " + info)

func _on_rollback_network_message_sent(msg, info):
	print("message was sent: " + msg + ", msg info: " + info)

func _on_send_message_button_pressed():
	netcode.send_message(message.text)
	return # Replace with function body.

func _on_check_box_toggled(toggled_on: bool):
	isLANConnection = toggled_on
	print("isLocal set to " + str(isLANConnection))
	return # Replace with function body.

func _on_start_client_button_pressed():
	netcode.set_server_local(isLANConnection)
	netcode.start_client()
	netcode.set_client_address(clientAddress.text)
	var port = int(clientPort.text)
	netcode.set_client_port(port)
	netcode.set_client()
	netcode.start_receive_loop()
	return # Replace with function body.
