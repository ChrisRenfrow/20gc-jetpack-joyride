extends Node2D

var speed: float = 100

func _process(delta: float) -> void:
	$BG.scroll_offset += Vector2.LEFT * speed * delta
