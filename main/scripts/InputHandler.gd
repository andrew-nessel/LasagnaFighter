class_name InputHandler extends Node

var current_input = InputHolder.new()

func  pollInput():
	var input_frame = current_input
	current_input = InputHolder.new()
	return input_frame
	

func _input(event):
	if event.is_action_released("lightAttack"):
		current_input.A_Press = false
		current_input.A_Release = true
	elif event.is_action_pressed("lightAttack"):
		current_input.A_Press = true
		current_input.A_Release = false
	
	if event.is_action_pressed("up"):
		if current_input.direction == InputHolder.Direction.RIGHT:
			current_input.direction = InputHolder.Direction.UP_RIGHT
		elif current_input.direction == InputHolder.Direction.LEFT:
			current_input.direction = InputHolder.Direction.UP_LEFT
		else:
			current_input.direction = InputHolder.Direction.UP
	elif event.is_action_pressed("down"):
		if current_input.direction == InputHolder.Direction.RIGHT:
			current_input.direction = InputHolder.Direction.DOWN_RIGHT
		elif current_input.direction == InputHolder.Direction.LEFT:
			current_input.direction = InputHolder.Direction.DOWN_LEFT
		else:
			current_input.direction = InputHolder.Direction.DOWN
	elif event.is_action_pressed("right"):
		if current_input.direction == InputHolder.Direction.LEFT:
			current_input.direction = InputHolder.Direction.NEUTRAL
		else:
			if current_input.direction == InputHolder.Direction.UP:
				current_input.direction = InputHolder.Direction.UP_RIGHT
			elif current_input.direction == InputHolder.Direction.DOWN:
				current_input.direction = InputHolder.Direction.DOWN_RIGHT
			else:
				current_input.direction = InputHolder.Direction.RIGHT
	elif event.is_action_pressed("left"):
		if current_input.direction == InputHolder.Direction.RIGHT:
			current_input.direction = InputHolder.Direction.NEUTRAL
		else:
			if current_input.direction == InputHolder.Direction.UP:
				current_input.direction = InputHolder.Direction.UP_LEFT
			elif current_input.direction == InputHolder.Direction.DOWN:
				current_input.direction = InputHolder.Direction.DOWN_LEFT
			else:
				current_input.direction = InputHolder.Direction.LEFT
	return

func _process(delta):
	
	if Input.is_action_pressed("lightAttack"):
		current_input.A_Press = true
		current_input.A_Release = false
	
	if Input.is_action_pressed("up"):
		if current_input.direction == InputHolder.Direction.RIGHT:
			current_input.direction = InputHolder.Direction.UP_RIGHT
		elif current_input.direction == InputHolder.Direction.LEFT:
			current_input.direction = InputHolder.Direction.UP_LEFT
		else:
			current_input.direction = InputHolder.Direction.UP

	if Input.is_action_pressed("down"):
		if current_input.direction == InputHolder.Direction.RIGHT:
			current_input.direction = InputHolder.Direction.DOWN_RIGHT
		elif current_input.direction == InputHolder.Direction.LEFT:
			current_input.direction = InputHolder.Direction.DOWN_LEFT
		else:
			current_input.direction = InputHolder.Direction.DOWN
	
	if Input.is_action_pressed("right"):
		if current_input.direction == InputHolder.Direction.LEFT:
			current_input.direction = InputHolder.Direction.NEUTRAL
		else:
			if current_input.direction == InputHolder.Direction.UP:
				current_input.direction = InputHolder.Direction.UP_RIGHT
			elif current_input.direction == InputHolder.Direction.DOWN:
				current_input.direction = InputHolder.Direction.DOWN_RIGHT
			else:
				current_input.direction = InputHolder.Direction.RIGHT
		
	if Input.is_action_pressed("left"):
		if current_input.direction == InputHolder.Direction.RIGHT:
			current_input.direction = InputHolder.Direction.NEUTRAL
		else:
			if current_input.direction == InputHolder.Direction.UP:
				current_input.direction = InputHolder.Direction.UP_LEFT
			elif current_input.direction == InputHolder.Direction.DOWN:
				current_input.direction = InputHolder.Direction.DOWN_LEFT
			else:
				current_input.direction = InputHolder.Direction.LEFT
	return
