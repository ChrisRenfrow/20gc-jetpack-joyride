class_name SegmentManager extends Node2D

enum SegmentType {
	ZAPPER,
	LASER,
	MISSILE,
	COIN,
}

@export var segment_weights := {
	SegmentType.ZAPPER: 5.0,
	SegmentType.LASER: 2.0,
	SegmentType.MISSILE: 2.0,
	SegmentType.COIN: 1.0
}

var scroll_speed: float:
	get: return Globals.scroll_speed

var distance: float:
	get: return Globals.distance

var _segments := {
	SegmentType.ZAPPER: [] as Array[PackedScene],
	SegmentType.LASER: [] as Array[PackedScene],
	SegmentType.MISSILE: [] as Array[PackedScene],
	SegmentType.COIN: [] as Array[PackedScene],
}

var _active_segment: BaseSegment
var _active_segment_type: SegmentType

var _active_overlay_segment: BaseSegment
# Can only be MISSILE, for now?
var _active_overlay_segment_type: SegmentType

var _queued_segment: BaseSegment
var _queued_segment_type: SegmentType

var _weighted_segments: Dictionary:
	get: return segment_weights

func _ready() -> void:
	for segment_type in _segments.keys():
		var type_name = SegmentType.find_key(segment_type).to_lower() + "s"
		_segments[segment_type] = _load_segments_from_path("res://assets/segments/" + type_name)
		prints("Loaded", _segments[segment_type].size(), type_name, "segments")

	_queue_random_segment()

func _process(_delta: float) -> void:
	_try_spawn_queued_segment()

func _queue_random_segment() -> void:
	print("Queuing random segment:")
	var picked_type = _weighted_choice(_weighted_segments)
	print("Picked type: ", SegmentType.find_key(picked_type))
	_queued_segment = _get_random_segment_of_type(picked_type)
	_queued_segment_type = picked_type
	print("Selected segment ", _queued_segment.name)

func _get_random_segment_of_type(type: SegmentType) -> BaseSegment:
	return _segments[type].pick_random().instantiate()

func _try_spawn_queued_segment() -> void:
	var active_segment_done = not is_instance_valid(_active_segment)
	var active_overlay_segment_done = not is_instance_valid(_active_overlay_segment)
	match [_queued_segment_type, active_segment_done]:
		[SegmentType.MISSILE, _] when active_overlay_segment_done:
			if _active_segment_type != SegmentType.LASER or _active_segment_type == SegmentType.LASER and active_segment_done:
				_spawn_queued_segment()
		[SegmentType.LASER, true] when active_overlay_segment_done:
			_spawn_queued_segment()
		[SegmentType.ZAPPER, true], [SegmentType.COIN, true]:
			_queued_segment.global_position.x = get_viewport_rect().size.x + 10
			_spawn_queued_segment()

func _spawn_queued_segment() -> void:
	if _queued_segment_type == SegmentType.MISSILE:
		_active_overlay_segment = _queued_segment
		_active_overlay_segment_type = SegmentType.MISSILE
	else:
		_active_segment = _queued_segment
		_active_segment_type = _queued_segment_type

	add_child(_queued_segment)
	_queue_random_segment()

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
			var full_path = path + "/" + file_name
			var scene = load(full_path) as PackedScene
			if not scene:
				push_error("Failed to load scene: " + full_path)
			elif not scene.instantiate() is BaseSegment:
				push_error("Scene is not a BaseSegment: " + full_path)
			else:
				segments.append(scene)
		file_name = dir.get_next()

	dir.list_dir_end()

	if segments.size() == 0:
		prints("No segments found under", path)

	return segments


# Probably should go in a utility file or something
## choices should be keyed with the option, with the value being a float for the weight
func _weighted_choice(choices: Dictionary) -> Variant:
	var sum_weight: float = 0.0
	for option in choices.keys():
		sum_weight += choices[option]

	var roll = randf_range(0.0, sum_weight)
	var cursor: float = 0
	for option in choices.keys():
		cursor += choices[option]
		if cursor >= roll:
			return option
	return
