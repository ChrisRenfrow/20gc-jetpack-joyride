extends Control

@onready var start_button := %StartButton

var _state := Globals.GameState.START:
	set(state):
		Globals.game_state = state
	get: return Globals.game_state

func _on_start_button_pressed() -> void:
	start_button.hide()
	_state = Globals.GameState.ACTIVE
