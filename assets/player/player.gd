extends CharacterBody2D

## Hit hazard, KO'd
signal hit
## Hit coin
signal coin_get
## Firing the jetpack
signal firing 

@export var player_gravity = 500
@export var jetpack_thrust = 600
@export var max_velocity = 600

var dead = false

func _ready() -> void:
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not dead and Input.is_action_pressed("jump"):
		velocity.y -= jetpack_thrust * delta
		animate_firing()
	else:
		velocity.y += player_gravity * delta
		animate_idle()
		
	velocity.y = minf(velocity.y, max_velocity)
	
	if move_and_collide(velocity * delta):
		velocity = Vector2.ZERO
	else:
		position.y += velocity.y * delta

func _on_hitzone_body_entered(body: Node2D) -> void:
	if body.is_in_group("hazard"):
		print("Hit hazard, game-over.")
		dead = true
		hit.emit()
	elif body.is_in_group("coin"):
		print("Coin touched")
		body.queue_free()
		coin_get.emit()

func animate_firing():
	$JetpackSprite.play("firing")
	$JetpackSprite/BulletParticles.emitting = true
	$JetpackSprite/ExhaustParticles.emitting = true
	$JetpackSprite/CasingParticles.emitting = true
	
func animate_idle():
	$JetpackSprite.play("idle")
	$JetpackSprite/BulletParticles.emitting = false
	$JetpackSprite/ExhaustParticles.emitting = false
	$JetpackSprite/CasingParticles.emitting = false
