@tool
class_name Zapper extends Hazard

## The length of the zapper, updates in editor
@export var arc_length: float = 500:
	set(len):
		arc_length = len
		if is_node_ready():
			_setup()

## The beam's angle of rotation in degrees, updates in the editor
@export var angle_degrees: float = 0:
	set(rot):
		angle_degrees = rot
		rotation_degrees = rot
	get: return rotation_degrees

var scroll_speed: float:
	get: return Globals.scroll_speed

@onready var trode_a: AnimatedSprite2D = $TrodeA
@onready var trode_b: AnimatedSprite2D = $TrodeB
@onready var arc: Sprite2D = $Arc
@onready var beam_shape: CollisionShape2D = $BeamShape

func _init(t=HazardType.ZAPPER) -> void:
	super(t)

func _ready() -> void:
	_setup()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	position.x -= scroll_speed * delta
	# Bounds checking
	if trode_a.global_position.x <= -10 and trode_b.global_position.x <= -10:
		queue_free()

func _setup():
	var trode_sprite_frames: SpriteFrames = trode_a.get_sprite_frames()
	var trode_sprite_size = trode_sprite_frames.get_frame_texture("default", 0).get_size()
	trode_sprite_size *= trode_a.scale

	var new_shape: CapsuleShape2D = beam_shape.shape.duplicate()
	# Just a little off the top to account for empty space on sprite (5px on each side)
	new_shape.height = arc_length + trode_sprite_size.x - (5 * 2)
	beam_shape.shape = new_shape
	beam_shape.position.x = arc_length / 2
	arc.region_rect.size.x = arc_length
	arc.position.x = arc_length / 2
	trode_b.position.x = arc_length
