class_name MatchWrapper
extends Node2D

@export var fHandler : FightingHandler

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func start_match():
	fHandler.start_match()
	return

func makePlayerOne(isP1 : bool) -> void:
	fHandler.makePlayerOne(isP1)
	return

func connectToInput(f : Callable) -> void:
	fHandler.new_input.connect(f)
	return

func addOppenentInput(input : InputHolder, timing : int) -> void:
	fHandler.addOppenentInput(input, timing)
	return
