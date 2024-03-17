extends Node

@export var player1 : PlayerHandler
@export var player2 : PlayerHandler
@export var inputManager : InputHandler
var player1InputList : Array[InputHolder]
var player2InputList : Array[InputHolder]
var current_timing
var timing = .016

func _ready():
	current_timing = timing
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
	current_timing -= delta
	if(current_timing < 0):
		var input1 = inputManager.pollInput()
		var input2 = InputHolder.new()
		player1.simulatePlayerFrame(input1)
		player2.simulatePlayerFrame(input2)
		current_timing = timing
