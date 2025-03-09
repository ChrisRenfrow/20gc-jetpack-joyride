extends Node

const INITIAL_SPEED: float = 150

enum GameState {
	START,
	ACTIVE,
	HIT,
	GAMEOVER,
}

signal scroll_speed_changed(new_speed: float)

var scroll_speed: float = 0:
	set(value):
		scroll_speed = value
		scroll_speed_changed.emit(value)

var distance: float = 0.0
var coins: int = 0
var game_state: GameState = GameState.START:
	set(state):
		print("Global game state change: ", GameState.find_key(state))
		match state:
			GameState.ACTIVE:
				scroll_speed = INITIAL_SPEED

		game_state = state
