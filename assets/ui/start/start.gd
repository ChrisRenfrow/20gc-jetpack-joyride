extends Control

@onready var start_prompt: Label = %StartPrompt

func _ready() -> void:
	_start_prompt_setup()

	Globals.game_state_changed.connect(_on_game_state_change)
	hide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		Globals.game_state = Globals.GameState.ACTIVE
		set_process(false)

func _on_game_state_change(state) -> void:
	if state == Globals.GameState.START:
		set_process(true)

func _start_prompt_setup():
	start_prompt.pivot_offset.x = start_prompt.size.x / 2

	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_loops()
	tween.tween_property(start_prompt, "scale", Vector2(.9,.9), 1)
	tween.tween_property(start_prompt, "scale", Vector2.ONE, 1)
