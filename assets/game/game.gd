class_name Game
extends Node2D

const MAX_SPEED: float = 500
const SPEED_INCREMENT: float = 5
const SPEED_INCREMENT_RATE: float = 5

@onready var stage: Node2D = $BasicStage
@onready var player: Player = $Player

@onready var hud: Control = %Hud
@onready var start_menu: Control = %Start
@onready var game_over_menu: Control = %GameOver

@onready var segment_manager: SegmentManager = $SegmentManager
@onready var minion_manager: MinionManager = $MinionManager

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

	Globals.game_state_changed.connect(_game_state_changed)
	player.player_state_change.connect(_on_player_state_change)

	_state = Globals.GameState.START

func _process(delta: float) -> void:
	match _state:
		Globals.GameState.ACTIVE:
			pass
		Globals.GameState.HIT:
			_speed = maxf(0.0, _speed - delta * 50.0)

	Globals.distance += _speed * delta

func _game_state_changed(new_state: Globals.GameState) -> void:
	match new_state:
		Globals.GameState.GAMEOVER:
			hud.hide()
			game_over_menu.show()
		Globals.GameState.START:
			hud.hide()
			start_menu.show()
			_reset_game()
		Globals.GameState.ACTIVE:
			start_menu.hide()
			hud.show()
			_start_game()

func _on_player_state_change(new_state: Player.PlayerState) -> void:
	match new_state:
		Player.PlayerState.HIT:
			_speed_inc_timer.stop()
			_state = Globals.GameState.HIT
		Player.PlayerState.KO:
			_state = Globals.GameState.GAMEOVER

func _start_game() -> void:
	segment_manager.start()
	minion_manager.start()
	player.start()

func _reset_game() -> void:
	stage.reset()
	segment_manager.reset()
	minion_manager.reset()
	player.reset()

func _on_speed_inc_timer_timeout() -> void:
	_speed = minf(_speed + SPEED_INCREMENT, MAX_SPEED)
