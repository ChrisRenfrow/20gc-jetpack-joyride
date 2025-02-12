extends Node2D

enum GameState {
	START,
	ACTIVE,
	HIT,
	GAMEOVER,
}

@onready var segment_manager: SegmentManager = $SegmentManager
@onready var stage: Node2D = $BasicStage
@onready var player: Player = $Player

var game_speed: float = 200.0
var _state := GameState.ACTIVE

func _ready() -> void:
	player.hit.connect(_on_player_hit)

func _process(delta: float) -> void:
	match _state:
		GameState.ACTIVE:
			game_speed += delta * 2.5
		GameState.HIT:
			game_speed = maxf(0.0, game_speed - delta * 50.0)

	Globals.scroll_speed = game_speed
	Globals.distance += game_speed * delta

func _on_player_hit() -> void:
	_state = GameState.HIT
