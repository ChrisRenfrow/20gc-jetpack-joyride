class_name SegmentManager extends Node2D

var available_segments: Array[PackedScene] = []
var active_segments: Array[Node2D] = []
var scroll_speed: float = 300.0

func _ready():
	load_segments()
	prints("Segments loaded:", available_segments)

func load_segments():
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
	if available_segments.is_empty():
		return
	var segment = available_segments[randi() % available_segments.size()].instantiate()
	segment.position.x = get_viewport_rect().size.x + 10
	active_segments.append(segment)
	add_child(segment)

func _process(delta: float) -> void:
	for segment in active_segments:
		segment.position.x -= scroll_speed * delta
		if segment.position.x + segment.segment_length < 0:
			segment.cleanup()
			active_segments.erase(segment)

	if active_segments.is_empty():
		spawn_next_segment()
	elif active_segments[-1].position.x + active_segments[-1].segment_length < get_viewport_rect().size.x:
		spawn_next_segment()
