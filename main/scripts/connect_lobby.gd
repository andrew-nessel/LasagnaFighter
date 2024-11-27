extends Control

@export var address_text : TextEdit
@export var port_text : TextEdit

func _on_button_pressed() -> void:
	print(address_text.text + ":" + port_text.text)
	LobbyClient.start_lobby_client(address_text.text, port_text.text)
	pass # Replace with function body.


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	pass # Replace with function body.
