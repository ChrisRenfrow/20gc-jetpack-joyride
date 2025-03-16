extends Control

@onready var reason_text: Label = %ReasonText
@onready var distance_value_label: Label = %DistanceValue
@onready var coin_value_label: Label = %CoinsValue
@onready var new_game_button: Button = %NewGameButton

var _state: Globals.GameState:
	set(state):
		Globals.game_state = state
	get: return Globals.game_state

func _ready() -> void:
	Globals.game_state_changed.connect(_on_game_state_change)
	hide()

func _on_game_state_change(state: Globals.GameState) -> void:
	if state == Globals.GameState.GAMEOVER:
		reason_text.text = Globals.get_gameover_reason_message()
		distance_value_label.text = Globals.get_formatted_distance()
		coin_value_label.text = str(Globals.coins)

func _on_new_game_button_pressed() -> void:
	_state = Globals.GameState.START
	hide()
