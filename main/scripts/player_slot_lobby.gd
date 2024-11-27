extends Node

@export var playerLabel : Label
@export var readyLabel : Label
var is_full = false
var is_ready = false

func _ready() -> void:
	readyLabel.visible = false

func set_label_text(s : String) -> void:
	playerLabel.text = s
func set_is_full(b : bool) -> void:
	is_full = b
func get_is_full() -> bool:
	return is_full
func set_is_ready(b : bool) -> void:
	is_ready = b
	readyLabel.visible = b
func get_is_ready() -> bool:
	return is_ready
