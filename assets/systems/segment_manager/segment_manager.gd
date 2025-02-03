class_name SegmentManager extends Node2D

var available_segments: Array[PackedScene] = []
var active_segments: Array[Node2D] = []
var scroll_speed: float = 300.0
var distance_since_last_segment: float = 0.0

func _ready():
	_load_segments()
	prints("Segments loaded:", available_segments)

func _load_segments():
	available_segments.append_array(_load_segments_from_path("res://assets/segments/"))

func _load_segments_from_path(path: String) -> Array[PackedScene]:
	prints("Loading segments from", path)
	var segments: Array[PackedScene] = []

	var dir = DirAccess.open(path)
	if not dir:
		push_error("Failed to open directory: " + path)
		return segments

	var error = dir.list_dir_begin()
	if error != OK:
		push_error("Failed to begin directory listing: " + path)
		return segments

	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and not file_name.begins_with("."):
			segments.append_array(_load_segments_from_path(path + "/" + file_name))
		elif file_name.ends_with(".tscn"):
			prints("Found", file_name)
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

func spawn_next_segment():
	print("Spawning new segment...")
	if available_segments.is_empty():
		return
	var segment = available_segments[randi() % available_segments.size()].instantiate()
	print("Selected segment \"", segment.name)
	segment.position.x = get_viewport_rect().size.x
	active_segments.append(segment)
	add_child(segment)

func _process(delta: float) -> void:
	distance_since_last_segment += scroll_speed * delta

	if active_segments.is_empty():
		spawn_next_segment()
	elif active_segments.front().length - distance_since_last_segment <= 0:
		distance_since_last_segment = 0.0
		spawn_next_segment()
	elif active_segments.front().is_queued_for_deletion():
		active_segments.pop_front()
