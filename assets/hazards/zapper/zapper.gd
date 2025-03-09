@tool
class_name Zapper
extends StaticBody2D

## The length of the zapper, updates in editor
@export var arc_length: float = 256.0:
	set(len):
		arc_length = len
		_setup()
	get():
		return arc_length

## The beam's angle of rotation in degrees, updates in the editor
@export var angle_degrees: float = 0:
	set(rot):
		angle_degrees = rot
		rotation_degrees = rot

var scroll_speed: float:
	get: return Globals.scroll_speed

func _ready() -> void:
	_setup()

func _process(delta: float) -> void:
	position.x -= scroll_speed * delta
	# Bounds checking
	if $TrodeA.global_position.x <= -10 and $TrodeB.global_position.x <= -10:
		queue_free()

func _setup():
	var new_shape: RectangleShape2D = $BeamShape.shape.duplicate()
	new_shape.size.x = arc_length
	$BeamShape.shape = new_shape
	$BeamShape.position.x = arc_length / 2
	$Arc.region_rect.size.x = arc_length
	$Arc.position.x = arc_length / 2
	$TrodeB.position.x = arc_length
