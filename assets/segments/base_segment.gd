class_name BaseSegment extends Node2D

var _children: Array = []

var _child_count: int:
	get: return _children.size()

func cleanup():
	prints("Cleanup called for", name)
	queue_free()

func _process(_delta: float) -> void:
	_children = get_children()

	if _child_count == 0:
		cleanup()
