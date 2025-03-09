extends Control

@onready var distance_value_label: Label = %DistanceValue
@onready var coin_value_label: Label = %DistanceValue
@onready var new_game_button: Button = %NewGameButton

var _state: Globals.GameState:
	set(state):
		Globals.game_state = state
	get: return Globals.game_state

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	coin_value_label.text = str(Globals.coins)
	distance_value_label.text = Globals.get_formatted_distance()

func _on_new_game_button_pressed() -> void:
	Globals.game_state = Globals.GameState.START
	hide()
