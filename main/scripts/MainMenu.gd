extends Node2D

@export var player_name_line_edit : TextEdit

func _on_server_button_pressed() -> void:
	LobbyClient.set_player_name(player_name_line_edit.text)
	LobbyClient.set_player_address("127.0.0.1")
	LobbyClient.set_player_port(9998)
	get_tree().change_scene_to_file("res://scenes/create_lobby.tscn")
	pass # Replace with function body.


func _on_client_button_pressed() -> void:
	LobbyClient.set_player_name(player_name_line_edit.text)
	LobbyClient.set_player_address("127.0.0.1")
	LobbyClient.set_player_port(9997)
	get_tree().change_scene_to_file("res://scenes/connect_lobby.tscn")
	pass # Replace with function body.
