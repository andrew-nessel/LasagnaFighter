class_name PlayerHandler extends Node

@export var speed = 10
@export var airspeed = 6
@export var initialjumpAmount = 50
@export var jumpLoss = 2
@export var gravity = 12
@export var state : PlayerState
@export var positionX : int
@export var positionY : int
@export var characterBody : Node2D
@export var floorY : int
@export var wallRight : int
@export var wallLeft : int
var animT = 0

var jumpAmount = 0
var grounded : bool

enum PlayerState {STATE_IDLE, STATE_BLOCK, STATE_HITSTUN, STATE_BLOCKSTUN, STATE_JUMPSQUAT, STATE_DASH, STATE_RUN, STATE_ACTION, STATE_RECOVERY}

func simulatePlayerFrame(frame_input : InputHolder):
	movePlayer(frame_input.direction)
	return
	

func rollbackPlayerFrame():
	return
	

func movePlayer(direction : InputHolder.Direction):
	if((direction == InputHolder.Direction.LEFT) || (direction == InputHolder.Direction.UP_LEFT)):
		if positionX > wallLeft:
			if grounded:
				positionX -= speed
			else:
				positionX -= airspeed
		else:
			positionX = wallLeft
	elif((direction == InputHolder.Direction.RIGHT) || (direction == InputHolder.Direction.UP_RIGHT)):
		if positionX < wallRight:
			if grounded:
				positionX += speed
			else:
				positionX += airspeed
		else:
			positionX = wallRight
	if((direction == InputHolder.Direction.UP) || (direction == InputHolder.Direction.UP_RIGHT) || (direction == InputHolder.Direction.UP_LEFT)):
		if grounded:
			jumpAmount = initialjumpAmount
		elif(jumpAmount > 0):
			jumpAmount -= jumpLoss
		positionY -= jumpAmount
	else:
		jumpAmount = 0
	if positionY < floorY:
		grounded = false
		positionY += gravity
	else:
		positionY = floorY
		grounded = true
	animT = 0
	return 

func _process(delta):
	animT += min((.016/delta), 1)
	characterBody.global_position = characterBody.global_position.lerp(intPositionToFloatVector2(), animT)

func intPositionToFloatVector2() -> Vector2:
	return Vector2(float(positionX), float(positionY))
	
func set_Floor(floor):
	floorY = floor
