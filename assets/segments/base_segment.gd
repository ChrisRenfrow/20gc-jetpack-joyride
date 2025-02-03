class_name BaseSegment extends Node2D

enum HazardType {
	Zapper,
	Laser,
	Missile,
}

var type: HazardType
var scroll_speed: float
var length: float
var visibility_notifier := VisibleOnScreenNotifier2D.new()

func cleanup():
	queue_free()

func _ready() -> void:
	scroll_speed = Globals.scroll_speed
	length = _get_total_length()
	Globals.scroll_speed_changed.connect(_set_scroll_speed)
	visibility_notifier.rect.size.y = 50
	visibility_notifier.rect.size.x = length
	visibility_notifier.screen_exited.connect(_on_screen_exit)
	add_child(visibility_notifier)
	prints("Segment ready with length:", length)

func _process(delta: float) -> void:
	# We move the visibility notifier to simulate movement while letting the
	# hazards handle their movment independently
	visibility_notifier.position.x += scroll_speed * delta

func _set_scroll_speed(new_speed: float) -> void:
	scroll_speed = new_speed

func _on_screen_exit() -> void:
	if visibility_notifier.global_position.x <= 0:
		cleanup()

## Calculates the space needed for all segment events (lasers, missiles, zappers)
## to conclude
func _get_total_length() -> float:
	print("Calculating total length of segment \"", name, "\"...")
	# This is calculated based on the current speed, so we shouldn't alter the speed mid-segment if possible
	var time_based_length := _get_time_based_hazard_required_time() * scroll_speed
	prints("Time-based length:", time_based_length, "Speed:", scroll_speed)
	var zapper_length := _get_zapper_required_space()
	prints("Zapper length:", zapper_length)
	prints("Required total time:", max(time_based_length, zapper_length))

	return max(time_based_length, zapper_length)

func _get_time_based_hazard_required_time() -> float:
	var total_time := 0.0
	var time_based_hazard_objs := get_children().filter(func(c): return c is Laser or c is Missile)
	for hazard in time_based_hazard_objs:
		prints("Found time-based hazard:", hazard.name)
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
