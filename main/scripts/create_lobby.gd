extends Control

@export var spin_box : SpinBox
var lobby_scene = preload("res://scenes/lobby.tscn").instantiate()


func _on_create_button_pressed() -> void:
	LobbyClient.set_total_player_number(int(spin_box.value))
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")
	LobbyClient.start_lobby_server(9999)
	pass # Replace with function body.

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	pass # Replace with function body.
