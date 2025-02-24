extends Node2D

@onready var shrapnel = $Shrapnel
@onready var blast = $Blast
@onready var smoke = $Smoke

func explode() -> void:
	blast.emitting = true
	shrapnel.emitting = true
	smoke.emitting = true
	await get_tree().create_timer(2).timeout
	queue_free()
