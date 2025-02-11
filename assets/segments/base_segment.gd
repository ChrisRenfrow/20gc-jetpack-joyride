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

var scroll_speed: float

func cleanup():
	prints("Cleanup called for", name)
	queue_free()

func _ready() -> void:
	scroll_speed = Globals.scroll_speed
	Globals.scroll_speed_changed.connect(_set_scroll_speed)

func _process(_delta: float) -> void:
	# If the segment has no more children, it means they've all moved off screen and
	# therefore the segment is finished, we can free the whole segment.
	if get_child_count() == 0:
		cleanup()

func _set_scroll_speed(new_speed: float) -> void:
	scroll_speed = new_speed
