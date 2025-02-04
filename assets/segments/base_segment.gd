class_name BaseSegment extends Node2D

# NOTE: Keeping this around as an idea for the future
# enum SegmentType {
# 	## Default segments can be overlaid by OVERLAY types (e.g. zappers, coins)
# 	DEFAULT,
# 	## Exclusive segments are exclusively on-screen until complete (e.g. lasers)
# 	EXCLUSIVE,
# 	## Overlay segments can occur during other segments (e.g. missiles)
# 	OVERLAY,
# }

# var type := SegmentType.DEFAULT

## The kind of hazard(s) included in the segment determine how its length is calculated
enum SegmentCategory {
	## Zappers and coins
	SPATIAL,
	## Lasers and missiles
	TIMED,
}

var segment_category := SegmentCategory.SPATIAL
var scroll_speed: float
var length: float
var visibility_notifier := VisibleOnScreenNotifier2D.new()

func cleanup():
	prints("Cleanup called for", name)
	queue_free()

func _ready() -> void:
	scroll_speed = Globals.scroll_speed
	Globals.scroll_speed_changed.connect(_set_scroll_speed)

	if segment_category == SegmentCategory.TIMED:
		var required_time = _get_time_based_hazard_required_time()
		_init_cleanup_timer(required_time)
	else:
		length = _get_zapper_required_space()
		visibility_notifier.rect.size.y = 50
		visibility_notifier.rect.size.x = length
		visibility_notifier.screen_exited.connect(_on_screen_exit)
		# _debug_visibility_notifier(visibility_notifier)
		# add_child(visibility_notifier)

	prints("Segment ready with length:", length)

func _process(delta: float) -> void:
	# We move the visibility notifier to simulate movement while letting the
	# hazards handle their movment independently
	visibility_notifier.position.x -= scroll_speed * delta

	# If the segment has no more children, it means they've all moved off screen and
	# therefore the segment is finished, we can free the whole segment.
	if get_child_count() == 0:
		cleanup()

func _set_scroll_speed(new_speed: float) -> void:
	scroll_speed = new_speed

func _on_screen_exit() -> void:
	print("On-screen notifier off screen for ", name)
	if visibility_notifier.global_position.x <= 0:
		cleanup()

func _debug_visibility_notifier(notifier: VisibleOnScreenNotifier2D) -> void:
	var debug_rect := ColorRect.new()
	debug_rect.size = visibility_notifier.rect.size
	debug_rect.color = Color(1, 0, 0, 0.3)
	notifier.add_child(debug_rect)

## For timed hazards: Generates a Timer with wait-time and set to call cleanup() on timeout.
func _init_cleanup_timer(time: float) -> void:
	prints("Initializing cleanup timer for", time, "secs")
	var timer := Timer.new()
	timer.name = "AutoCleanupTimer"
	timer.wait_time = time
	timer.autostart = true
	timer.timeout.connect(cleanup)
	add_child(timer)

## Calculates the space needed for all segment events (lasers, missiles, zappers)
## to conclude
func _get_total_length() -> float:
	print("Calculating total length of segment \"", name, "\"...")
	# This is calculated based on the current speed, so we shouldn't alter the speed mid-segment if possible
	match segment_category:
		SegmentCategory.TIMED:
			var time_based_length := _get_time_based_hazard_required_time() * scroll_speed
			prints("Time-based length:", time_based_length, "Speed:", scroll_speed)
			return time_based_length
		SegmentCategory.SPATIAL:
			var zapper_length := _get_zapper_required_space()
			prints("Zapper length:", zapper_length)
			return zapper_length
		_:
			return 0.0

func _get_time_based_hazard_required_time() -> float:
	var total_time := 0.0
	var time_based_hazard_objs := get_children().filter(func(c): return c is Laser or c is Missile)
	for hazard in time_based_hazard_objs:
		prints("Found time-based hazard", hazard.name, "in", name)
		var time = hazard.get_screen_enter_time() + hazard.get_total_onscreen_time()
		total_time = max(total_time, time)
		prints("Time required:", total_time, "seconds")

	return total_time

func _get_zapper_required_space() -> float:
	var total_length := 0.0
	var zapper_objs := get_children().filter(func(c): return c is Zapper)

	for zapper in zapper_objs:
		prints("Found zapper:", zapper.name)
		total_length = max(total_length, zapper.get_total_horizontal_space())
		prints("Length:", total_length)

	return total_length
