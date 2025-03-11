@tool
extends GPUParticles2D

func _ready() -> void:
	amount_ratio = randf_range(0.2, 1.0)
	finished.connect(_cleanup)

func _cleanup() -> void:
	if not Engine.is_editor_hint():
		queue_free()
