class_name Player
extends CharacterBody2D

enum PlayerState {
	## Placeholder state for when the player enters the scene at the start of a round
	INTRO,
	## Player input enabled, active play
	ACTIVE,
	## Player hit a hazard, falling to ground dramatically
	HIT,
	## Game-over
	KO,
}

signal hit

@export_group("Movement")
@export var player_gravity: float = 500.0
@export var jetpack_thrust: float = 600.0
@export var max_velocity: float = 600.0

@export_group("Debug")
@export var invincible: bool = false

@onready var hitbox: Area2D = $Hitbox
@onready var jetpack_sprite: AnimatedSprite2D = $JetpackSprite
@onready var bullet_particles: GPUParticles2D = $JetpackSprite/BulletParticles
@onready var exhaust_particles: GPUParticles2D = $JetpackSprite/ExhaustParticles
@onready var casing_particles: GPUParticles2D = $JetpackSprite/CasingParticles

var _is_dead := false
var _state := PlayerState.ACTIVE
var _bounce_count: int = 0

func _ready() -> void:
	hitbox.position = Vector2.ZERO
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	match _state:
		PlayerState.ACTIVE:
			_handle_movement(delta)
		PlayerState.HIT:
			_handle_hit_movement(delta)

func _process(_delat: float) -> void:
	_handle_animation()

func _handle_movement(delta: float) -> void:
	if _state == PlayerState.ACTIVE and Input.is_action_pressed("jump"):
		velocity.y -= jetpack_thrust * delta
	else:
		velocity.y += player_gravity * delta

	velocity.y = minf(velocity.y, max_velocity)
	if move_and_collide(velocity * delta):
		velocity = Vector2.ZERO
	else:
		position.y += velocity.y * delta

func _handle_hit_movement(delta: float) -> void:
	velocity.y += player_gravity * delta
	position.y += velocity.y * delta

	if move_and_collide(velocity * delta):
		if _bounce_count < 3:
			velocity.y = -300.0 * pow(0.5, _bounce_count)
			_bounce_count += 1
		else:
			velocity = Vector2.ZERO
			_state = PlayerState.KO

func _handle_animation() -> void:
	var is_jetpack_active := Input.is_action_pressed("jump")
	if is_jetpack_active and _state == PlayerState.ACTIVE:
		_activate_jetpack()
	else:
		_deactivate_jetpack()

func _on_hitzone_body_entered(body: Node2D) -> void:
	if _state != PlayerState.ACTIVE:
		return

	if body.is_in_group("hazard"):
		_handle_hazard_collision(body)
	elif body.is_in_group("coin"):
		_handle_coin_collision(body)

func _handle_hazard_collision(hazard: Node2D) -> void:
	print("Hit hazard, game-over.")
	# Missile case
	if hazard.has_method("explode"):
		hazard.explode()
	if not invincible:
		_state = PlayerState.HIT
		hit.emit()

func _handle_coin_collision(coin: Node2D) -> void:
	print("Coin touched")
	coin.queue_free()
	Globals.coins += 1

func _activate_jetpack() -> void:
	jetpack_sprite.play("firing")
	_set_particles_emission(true)

func _deactivate_jetpack() -> void:
	jetpack_sprite.play("idle")
	_set_particles_emission(false)

func _set_particles_emission(enabled: bool) -> void:
	bullet_particles.emitting = enabled
	exhaust_particles.emitting = enabled
	casing_particles.emitting = enabled
