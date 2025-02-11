extends StaticBody2D

var _move_speed: float:
	get: return Globals.scroll_speed

func _process(_delta: float) -> void:
	if global_position.x <= -10:
		queue_free()

func _physics_process(delta: float) -> void:
	position.x -= _move_speed * delta
