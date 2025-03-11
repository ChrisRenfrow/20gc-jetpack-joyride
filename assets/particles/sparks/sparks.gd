@tool
extends Node2D

## The probability of sparking per-tick
@export var spark_chance_per_tick: float = 0.01
## Whether it should enter the scene sparking
@export var sparking := false

@onready var spark_burst: PackedScene = load("res://assets/particles/sparks/spark_burst/spark_burst.tscn")

## Start spawning spark bursts at a random interval
func start() -> void:
	sparking = true

## Stop spawning spark bursts
func stop() -> void:
	sparking = false


func _process(_delta: float) -> void:
	if sparking and randf() <= spark_chance_per_tick:
		_spawn_spark_burst()

func _spawn_spark_burst():
	var particles: GPUParticles2D = spark_burst.instantiate()
	particles.emitting = true
	add_child(particles)
