class_name SegmentManager extends Node2D

## Maximum missiles per 100m
const MISSILE_MAX_FREQ := 1

enum State {
	## Default behavior, non-exclusive
	DEFAULT,
	## Lasers are on-screen, exclusive
	LASER,
}

@export var zapper_probability: float = 0.8
@export var laser_probability: float = 0.2
# Missiles can appear any time zappers (or coins) are on screen, so their probability needs to be pretty low
@export var missile_probability: float = 0.02
#@export var coin_probability: float = 0.4

var scroll_speed: float:
	get: return Globals.scroll_speed

var distance: float:
	get: return Globals.distance


var _state := State.DEFAULT
var _segments := {
	"zappers": [] as Array[PackedScene],
	"lasers": [] as Array[PackedScene],
	"missiles": [] as Array[PackedScene]
}

var _active_segments := {
	"zappers": [] as Array[BaseSegment],
	"lasers": [] as Array[BaseSegment],
	"missiles": [] as Array[BaseSegment]
}

var _num_active_segments: int = 0:
	get: return _active_segments.keys().reduce(
			func(c, k): return c + _active_segments.get(k).size(),
			0
		)

func _ready() -> void:
	for segment_type in _segments.keys():
		_segments[segment_type] = _load_segments_from_path("res://assets/segments/" + segment_type)
		prints("Loaded", _segments[segment_type].size(), segment_type, "segments")

func _process(_delta: float) -> void:
	_clean_inactive_segments()

	match _state:
		State.DEFAULT:
			_handle_default_state()
		State.LASER:
			_handle_laser_state()

func _load_segments_from_path(path: String) -> Array[PackedScene]:
	var segments: Array[PackedScene] = []
	var dir = DirAccess.open(path)
	if not dir:
		push_error("Failed to open directory: " + path)
		return segments

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if dir.current_is_dir() and not file_name.begins_with("."):
			segments.append_array(_load_segments_from_path(path + "/" + file_name))
		elif file_name.ends_with(".tscn"):
			var scene = load(path + "/" + file_name) as PackedScene
			if not scene:
				push_error("Failed to load scene: " + path + "/" + file_name)
				continue

			var instance = scene.instantiate()
			if not instance is BaseSegment:
				push_error("Scene is not a BaseSegment: " + path + "/" + file_name)
				instance.free()
				continue

			segments.append(scene)
		file_name = dir.get_next()

	dir.list_dir_end()

	if segments.size() == 0:
		prints("No segments found under", path)

	return segments

func _clean_inactive_segments() -> void:
	for segment_type in _active_segments.keys():
		var new_active_segments = _active_segments.get(segment_type).filter(
				func(segment): return is_instance_valid(segment)
			)
		_active_segments[segment_type] = new_active_segments

func _handle_default_state() -> void:
	if _try_spawn_laser():
		return

	_try_spawn_zapper()
	_try_spawn_missile()

func _handle_laser_state() -> void:
	if _active_segments["lasers"].is_empty():
		_state = State.DEFAULT

func _try_spawn_laser() -> bool:
	if randf() < laser_probability and not _segments.lasers.is_empty() and _num_active_segments == 0:
		_spawn_segment("lasers")
		_state = State.LASER
		return true
	return false

func _try_spawn_zapper() -> void:
	if randf() < zapper_probability and not _segments.zappers.is_empty() and _num_active_segments == 0:
		var segment = _spawn_segment("zappers")
		segment.global_position.x = get_viewport_rect().size.x

func _try_spawn_missile() -> void:
	if _active_segments["missiles"].size() > 0:
		return

	if randf() < missile_probability and not _segments.missiles.is_empty():
		_spawn_segment("missiles")

func _spawn_segment(type: String) -> BaseSegment:
	var segment = _segments[type].pick_random().instantiate()
	add_child(segment)
	_active_segments[type].append(segment)
	return segment
