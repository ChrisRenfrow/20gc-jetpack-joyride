extends Node2D

@onready var segment_manager: SegmentManager = $SegmentManager
@onready var stage: Node2D = $BasicStage
@onready var player: Player = $Player

var game_speed: float = 300.0

func _process(delta: float) -> void:
	game_speed += delta * 10

	Globals.scroll_speed = game_speed
	stage.speed = game_speed
