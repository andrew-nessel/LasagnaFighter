extends Node2D


@export var top_menu : Node2D
@export var online_menu : Node2D
@export var player_name_line_edit : TextEdit

func _ready() -> void:
	top_menu.set_visible(true)
	online_menu.set_visible(false)
	pass

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


func _on_singleplay_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/single_match.tscn")
	pass # Replace with function body.


func _on_onlineplay_button_pressed() -> void:
	top_menu.set_visible(false)
	online_menu.set_visible(true)
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
	pass # Replace with function body.


func _on_online_back_button_pressed() -> void:
	top_menu.set_visible(true)
	online_menu.set_visible(false)
	pass # Replace with function body.
