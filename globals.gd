extends Node

signal scroll_speed_changed(new_speed: float)

var scroll_speed: float = 300.0:
	set(value):
		scroll_speed = value
		scroll_speed_changed.emit(value)

var distance: float = 0.0
var coins: int = 0
