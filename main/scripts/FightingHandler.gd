class_name FightingHandler
extends Node

signal new_input

@export var player1 : PlayerHandler
@export var player2 : PlayerHandler
@export var inputManager : InputHandler
var player1InputList : Array[InputHolder]
var player2InputList : Array[InputHolder]
var worldState : WorldStateHandler
var current_timing
var timing = .016
var match_started = false
var isPlayerOne = true

func _ready():
	current_timing = timing
	worldState = WorldStateHandler.new()
	worldState.setPlayers(player1, player2)
	player1.positionX = 250
	player1.positionY = 500
	player1.floorY = 500
	player1.wallRight = 1100
	player1.wallLeft = 50
	player2.positionX = 900
	player2.positionY = 500
	player2.floorY = 500
	player2.wallRight = 1100
	player2.wallLeft = 50

func simulateFrame():
	return
	

func rollbackFrames():
	return
	

func _process(delta):
	if(match_started):
		current_timing -= delta
		if(current_timing < 0):
			var input1 = inputManager.pollInput()
			var input2 = InputHolder.new()
			if(isPlayerOne):
				if(player2InputList.size() > 0):
					input2 = player2InputList.back()
				player1InputList.push_back(input1)
				emit_signal("new_input", input1, player1InputList.size()-1)
				player1.simulatePlayerFrame(input1)
				player2.simulatePlayerFrame(input2)
			else:
				if(player1InputList.size() > 0):
					input2 = player1InputList.back()
				player2InputList.push_back(input1)
				emit_signal("new_input", input1, player2InputList.size()-1)
				player2.simulatePlayerFrame(input1)
				player1.simulatePlayerFrame(input2)
			current_timing = timing
			worldState.saveFrame()

func start_match() -> void:
	match_started = true
	pass
	

func makePlayerOne(isP1 : bool) -> void:
	isPlayerOne = isP1
	return
	

func addOppenentInput(input : InputHolder, t : int) -> void: #TODO add handling the timing data to add it to the appropriate spot in the list and do rollback
	if(isPlayerOne):
		player2InputList.push_back(input)
	else:
		player1InputList.push_back(input)
	return
