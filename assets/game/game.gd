extends Node2D

@onready var segment_manager: SegmentManager = $SegmentManager
@onready var stage: Node2D = $BasicStage
@onready var player: Player = $Player

var game_speed: float = 50.0

func _process(delta: float) -> void:
	game_speed += delta * 2.5

	Globals.scroll_speed = game_speed
	Globals.distance += game_speed * delta
	$Distance.text = str(Globals.distance)
