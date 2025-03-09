class_name Game
extends Node2D

const MAX_SPEED: float = 500
const SPEED_INCREMENT: float = 5
const SPEED_INCREMENT_RATE: float = 5

@onready var segment_manager: SegmentManager = $SegmentManager
@onready var stage: Node2D = $BasicStage
@onready var player: Player = $Player

var _speed_inc_timer := Timer.new()
var _state := Globals.GameState.START:
	set(state):
		Globals.game_state = state
	get: return Globals.game_state
var _speed: float = 0.0:
	set(speed):
		Globals.scroll_speed = speed
	get: return Globals.scroll_speed

func _ready() -> void:
	_speed_inc_timer.wait_time = SPEED_INCREMENT_RATE
	_speed_inc_timer.timeout.connect(_on_speed_inc_timer_timeout)
	add_child(_speed_inc_timer)

	player.hit.connect(_on_player_hit)

func _process(delta: float) -> void:
	match _state:
		Globals.GameState.ACTIVE:
			pass
		Globals.GameState.HIT:
			_speed = maxf(0.0, _speed - delta * 50.0)

	Globals.distance += _speed * delta

func _on_player_hit() -> void:
	_speed_inc_timer.stop()
	_state = Globals.GameState.HIT

func _on_speed_inc_timer_timeout() -> void:
	_speed = minf(_speed + SPEED_INCREMENT, MAX_SPEED)
