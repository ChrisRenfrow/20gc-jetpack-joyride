extends Node

const INITIAL_SPEED: float = 200

enum HazardType {
	LASER,
	MISSILE,
	ZAPPER,
	NONE,
}

enum GameState {
	START,
	ACTIVE,
	HIT,
	GAMEOVER,
}

signal game_state_changed(new_state: GameState)
signal game_speed_changed(new_speed: float)

var scroll_speed: float = 0:
	set(speed):
		game_speed_changed.emit(speed)
		scroll_speed = speed
var distance: float = 0.0
var coins: int = 0
## Set by Player when firing jetpack
var jetpack_firing := false
## Set when player touches hazard.
var gameover_hazard_name: String

var game_state: GameState = GameState.START:
	set(state):
		print("Global game state change: ", GameState.find_key(state))
		match state:
			GameState.START:
				reset_game()
			GameState.ACTIVE:
				scroll_speed = INITIAL_SPEED
			GameState.GAMEOVER:
				scroll_speed = 0

		game_state = state
		game_state_changed.emit(state)

func reset_game() -> void:
	scroll_speed = 0
	distance = 0
	coins = 0

func get_formatted_distance() -> String:
	return "%.2f" % (distance / 10.0) + "m"

func get_gameover_reason_message() -> String:
	if gameover_hazard_name == "none":
		return "Died of mysterious causes."

	var hazard_name = gameover_hazard_name
	var hazard_specific_messages = {
		"laser" = [
			"Lasers are not toys.",
			"Blinded by the light.",
			"Victim of DIY hair-removal.",
		],
		"missile" = [
			"Gotta blast!",
			"Another victim of military-industrial complex.",
			"You really blew that one.",
		],
		"zapper" = [
			"A real fan of electro-therapy.",
			"Shocking!",
			"Maybe lightning does strike the same place twice?",
		],
	}
	var generic_messages = [
		"Hit by {hazard}.",
		"Dreams dashed by {hazard}.",
		"The {hazard} won.",
		"Tried to make friends with a {hazard}.",
		"Learned {hazard}s are not conducive to long life.",
		"Found out {hazard}s hurt.",
		"Recommendation: Avoid {hazard}s.",
		"Went toward the {hazard}'s light.",
		"Have you tried avoiding the {hazard}s?",
		"Studies show that contact with {hazard}s is lethal.",
		"Touch grass, not {hazard}s.",
	]

	if randf() <= 0.5:
		var options = hazard_specific_messages.get(hazard_name)
		return options[randi() % options.size()]
	else:
		return generic_messages[randi() % generic_messages.size()].format({"hazard": hazard_name})
