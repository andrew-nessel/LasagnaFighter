class_name OnlineMatchWrapper
extends Node2D

@export var match_wrapper : MatchWrapper

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NetworkHandler.match_has_loaded()
	NetworkHandler.start_match.connect(start_match)
	NetworkHandler.opponenet_input.connect(handleOppenentInput)
	match_wrapper.makePlayerOne(NetworkHandler.get_is_player_one())
	match_wrapper.connectToInput(handleNewInput)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func start_match() -> void:
	match_wrapper.start_match()
	pass

func handleNewInput(input : InputHolder, timing : int) -> void:
	NetworkHandler.send_frame_data_message(input, timing)
	pass
	
func handleOppenentInput(input : InputHolder, timing : int) -> void:
	match_wrapper.addOppenentInput(input, timing)
	pass
