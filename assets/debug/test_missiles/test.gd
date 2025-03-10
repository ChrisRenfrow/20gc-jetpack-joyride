extends Node2D

var missile_scene := load("res://assets/hazards/missile/missile.tscn")
var missile_spawn_timer := Timer.new()
var screen_size: Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size

	missile_spawn_timer.wait_time = 1
	missile_spawn_timer.autostart = true
	missile_spawn_timer.timeout.connect(_on_missile_spawn_timer_timeout)
	add_child(missile_spawn_timer)

func _on_missile_spawn_timer_timeout() -> void:
	var missile = missile_scene.instantiate()

	missile.homing = true
	missile.position.y = randf_range(10, screen_size.y - 10)
	missile.show_homing_vector = false

	add_child(missile)
