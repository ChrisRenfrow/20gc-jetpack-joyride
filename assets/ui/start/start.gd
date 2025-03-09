extends Control

@onready var start_button := %StartButton

func _ready() -> void:
	hide()

func _on_start_button_pressed() -> void:
	Globals.game_state = Globals.GameState.ACTIVE
