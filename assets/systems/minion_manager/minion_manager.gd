extends Node2D

@export_group("Spawning")
## Seconds to wait before trying to spawn a minion
@export var minion_spawn_rate := 1.0
## The probability of whether a minion will spawn (0.0 - 1.0)
@export var minion_chance := 0.5:
	set(val):
		return clampf(val, 0.0, 1.0)

@export_group("Movement & Positioning")
## The minions base speed
@export var minion_base_speed: float = 200
## The random jitter to add to a minion's base speed
@export var minion_speed_jitter: float = 20
## The minions run speed modifier: minion_base_speed * minion_run_speed_modifier
@export var minion_run_speed_modifier: float = 1.3
## The y position of the minions
@export var minion_y_position: float = 0.0
## The y jitter to add as an offset (positive and negative) to spawn positioning
@export var minion_y_jitter: float = 5.0

var _minion_scene: PackedScene = load("res://assets/minion/minion.tscn")
var _spawn_rate_timer := Timer.new()

func _ready() -> void:
	_spawn_rate_timer.wait_time = minion_spawn_rate
	_spawn_rate_timer.autostart = true
	_spawn_rate_timer.timeout.connect(_spawn_rate_timer_timeout)
	add_child(_spawn_rate_timer)

func _spawn_minion():
	var minion = _minion_scene.instantiate()
	var direction = Vector2.LEFT if randf() >= 0.5 else Vector2.RIGHT

	minion.speed = minion_base_speed + randf_range(-minion_speed_jitter, minion_speed_jitter)
	minion.run_speed = minion.speed * minion_run_speed_modifier
	minion.facing = direction

	if direction == Vector2.LEFT:
		minion.global_position.x = get_viewport_rect().size.x + 50
	else:
		minion.global_position.x = -50

	minion.global_position.y = minion_y_position
	minion.global_position.y += randf_range(-minion_y_jitter, minion_y_jitter)

	add_child(minion)

func _spawn_rate_timer_timeout() -> void:
	if randf() >= minion_chance:
		_spawn_minion()
