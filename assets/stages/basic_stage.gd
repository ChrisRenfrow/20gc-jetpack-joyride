extends Node2D

var speed = 0.0:
	get: return Globals.scroll_speed

func reset() -> void:
	$BG.scroll_offset = Vector2.ZERO

func _process(delta: float) -> void:
	$BG.scroll_offset += Vector2.LEFT * speed * delta
