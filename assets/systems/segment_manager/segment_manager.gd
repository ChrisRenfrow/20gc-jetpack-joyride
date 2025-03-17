class_name SegmentManager extends Node2D

enum SegmentType {
	ZAPPER,
	LASER,
	MISSILE,
	COIN,
	NONE,
}

## Weighted distribution of segments by type (excluding missiles)
@export var segment_weights := {
	SegmentType.ZAPPER: 5.0,
	SegmentType.LASER: 2.0,
	SegmentType.COIN: 1.0
}

## The minimum number of seconds to wait to queue a missile segment
@export var missile_min_cooldown := 6.0;
## The maximum number of seconds to wait to queue a missile segment
@export var missile_max_cooldown := 48.0;
## The number of seconds to reduce the max missile cooldown per game speed increase
@export var missile_cooldown_dec_on_speed_inc := 1.0

var _original_missile_max_cooldown: float

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

var _active_missile_segment: BaseSegment
var _queued_missile_segment: BaseSegment
var _missile_cooldown_timer: Timer

var _queued_segment: BaseSegment
var _queued_segment_type: SegmentType

var _weighted_segments: Dictionary:
	get: return segment_weights

var _game_active := false:
	get: return Globals.game_state == Globals.GameState.ACTIVE

func reset() -> void:
	[_active_segment, _queued_segment, _active_missile_segment, _queued_missile_segment].map(
		func(segment):
			if is_instance_valid(segment):
				segment.queue_free())
	_active_segment_type = SegmentType.NONE
	_queued_segment_type = SegmentType.NONE
	missile_max_cooldown = _original_missile_max_cooldown

func start() -> void:
	_missile_timer_setup()
	_queue_random_segment()

func _ready() -> void:
	_original_missile_max_cooldown = missile_max_cooldown
	Globals.game_speed_changed.connect(_on_game_speed_change)

	for segment_type in _segments.keys():
		var type_name = SegmentType.find_key(segment_type).to_lower() + "s"
		_segments[segment_type] = _load_segments_from_path("res://assets/segments/" + type_name)
		prints("Loaded", _segments[segment_type].size(), type_name, "segments")

func _process(_delta: float) -> void:
	if _game_active:
		_try_spawn_queued_segment()
		_try_spawn_queued_missile_segment()

func _on_game_speed_change(_speed: float) -> void:
	if _game_active:
		missile_max_cooldown = maxf(missile_min_cooldown, missile_max_cooldown - missile_cooldown_dec_on_speed_inc)
		print("Missile max cooldown reduced: ", missile_max_cooldown)

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
	var missile_segment_active = is_instance_valid(_active_missile_segment)
	match [_queued_segment_type, active_segment_done]:
		[SegmentType.LASER, true] when not missile_segment_active:
			_spawn_queued_segment()
		[SegmentType.ZAPPER, true], [SegmentType.COIN, true]:
			_queued_segment.global_position.x = get_viewport_rect().size.x + 10
			_spawn_queued_segment()

func _spawn_queued_segment() -> void:
	print("Spawning queued segment: ", _queued_segment.name)
	add_child(_queued_segment)
	_active_segment = _queued_segment
	_active_segment_type = _queued_segment_type
	_queue_random_segment()

func _missile_timer_setup() -> void:
	_missile_cooldown_timer = Timer.new()
	_missile_cooldown_timer.one_shot = true
	_missile_cooldown_timer.autostart = true
	_missile_cooldown_timer.wait_time = randf_range(missile_min_cooldown, missile_max_cooldown)
	add_child(_missile_cooldown_timer)

func _try_spawn_queued_missile_segment() -> void:
	var missile_segment_queued = is_instance_valid(_queued_missile_segment)
	var missile_segment_active = is_instance_valid(_active_missile_segment)
	if _active_segment_type != SegmentType.LASER and \
		not missile_segment_active and missile_segment_queued:
			_spawn_queued_missile_segment()
	if _missile_cooldown_timer.is_stopped() and not missile_segment_queued:
		_queued_missile_segment = _get_random_segment_of_type(SegmentType.MISSILE)

func _spawn_queued_missile_segment() -> void:
	print("Spawning queued missile segment: ", _queued_missile_segment.name)
	_active_missile_segment = _queued_missile_segment
	add_child(_queued_missile_segment)
	_queued_missile_segment = null
	_missile_cooldown_timer.wait_time = randf_range(missile_min_cooldown, missile_max_cooldown)
	_missile_cooldown_timer.start()

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
