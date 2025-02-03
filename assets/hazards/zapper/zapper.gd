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

var scroll_speed := 0.0

## Returns the horizontal space (in pixels) taken up by this zapper including current offset.
func get_total_horizontal_space() -> float:
	return position.x + _base_horizontal_space()

## Returns the base horizontal space needed by just the beam itself based on angle and length.
func _base_horizontal_space() -> float:
	return abs(arc_length * cos(angle_degrees))

func _ready() -> void:
	Globals.scroll_speed_changed.connect(_set_scroll_speed)
	_setup()

func _process(delta: float) -> void:
	position.x -= scroll_speed * delta

func _set_scroll_speed(new_speed: float) -> void:
	scroll_speed = new_speed

func _setup():
	var new_shape: RectangleShape2D = $BeamShape.shape.duplicate()
	new_shape.size.x = arc_length
	$BeamShape.shape = new_shape
	$BeamShape.position.x = arc_length / 2
	$Arc.region_rect.size.x = arc_length
	$Arc.position.x = arc_length / 2
	$TrodeB.position.x = arc_length
