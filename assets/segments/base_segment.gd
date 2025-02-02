class_name BaseSegment extends Node2D

@export var segment_length: float
# Ideas for more parameters/data
# - difficulty
# - min/max speed

func _ready() -> void:
	pass

func cleanup():
	queue_free()
