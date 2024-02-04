class_name InputHolder

enum Direction {ERROR, DOWN_LEFT, DOWN, DOWN_RIGHT, LEFT, NEUTRAL, RIGHT, UP_LEFT, UP, UP_RIGHT} #Direction enum based on numpad notation
var direction : Direction
var A_Press   : bool
var A_Release : bool
var B_Press   : bool
var B_Release : bool
var C_Press   : bool
var C_Release : bool
var D_Press   : bool
var D_Release : bool

func _init():
	direction = Direction.NEUTRAL
	A_Press   = false
	A_Release = false
	B_Press   = false
	B_Release = false
	C_Press   = false
	C_Release = false
	D_Press   = false
	D_Release = false
