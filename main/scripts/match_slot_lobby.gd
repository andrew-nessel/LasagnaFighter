extends Node

@export var matchLabel : Label
@export var playerSlot1 : Node
@export var playerSlot2 : Node
@export var readyButton : Node
#var is_full = false
#var is_ready = false

func _ready() -> void:
	playerSlot1.set_label_text("")
	playerSlot1.set_is_ready(false)
	playerSlot1.set_is_full(false)
	playerSlot2.set_label_text("")
	playerSlot2.set_is_full(false)
	playerSlot2.set_is_ready(false)

func set_label_text(s : String) -> void:
	matchLabel.text = s
#func set_is_full(b : bool) -> void:
	#is_full = b
func get_is_full() -> bool:
	return playerSlot1.get_is_full() and playerSlot2.get_is_full()
func get_is_ready() -> bool:
	return playerSlot1.get_is_ready() and playerSlot2.get_is_ready()
func get_player_slot(i : int):
	if i > 0:
		return playerSlot2
	return playerSlot1
func get_ready_button():
	return readyButton
func disable_ready_button():
	readyButton.set_disabled(true)
func enable_ready_button():
	readyButton.set_disabled(false)
func set_slot_ready(slot_number : int):
	var ps = get_player_slot(slot_number)
	ps.set_is_ready(!ps.get_is_ready())
func clear_all_ready():
	playerSlot1.set_is_ready(false)
	playerSlot2.set_is_ready(false)
	
