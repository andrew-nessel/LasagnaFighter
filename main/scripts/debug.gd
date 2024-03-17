extends Node

func _signal_from_plugin(obj, pos):
	print("we got signal dog: " + str(pos))
