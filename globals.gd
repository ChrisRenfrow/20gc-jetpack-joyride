extends Node

const INITIAL_SPEED: float = 150

enum GameState {
	START,
	ACTIVE,
	HIT,
	GAMEOVER,
}

signal game_state_changed(new_state: GameState)

var scroll_speed: float = 0:
	set(value):
		scroll_speed = value

var distance: float = 0.0
var coins: int = 0

var game_state: GameState = GameState.START:
	set(state):
		print("Global game state change: ", GameState.find_key(state))
		match state:
			GameState.ACTIVE:
				scroll_speed = INITIAL_SPEED
			GameState.START:
				reset_game()

		game_state = state
		game_state_changed.emit(state)

func reset_game() -> void:
	scroll_speed = 0
	distance = 0
	coins = 0

func get_formatted_distance() -> String:
	return "%.2f" % (distance / 10.0) + "m"
