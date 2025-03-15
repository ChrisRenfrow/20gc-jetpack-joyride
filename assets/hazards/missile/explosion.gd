extends Node2D

@onready var shrapnel = $Shrapnel
@onready var blast = $Blast
@onready var smoke = $Smoke

var _queue_explode := false

func explode() -> void:
	_queue_explode = true

func _process(_delta: float) -> void:
	if _queue_explode:
		_explode()

func _explode() -> void:
	blast.emitting = true
	shrapnel.emitting = true
	smoke.emitting = true
	await get_tree().create_timer(2).timeout
	queue_free()
