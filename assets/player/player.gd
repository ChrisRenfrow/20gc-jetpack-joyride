class_name Player
extends CharacterBody2D

signal hit

@export_group("Movement")
@export var player_gravity: float = 500.0
@export var jetpack_thrust: float = 600.0
@export var max_velocity: float = 600.0

@onready var hitbox: Area2D = $Hitbox
@onready var jetpack_sprite: AnimatedSprite2D = $JetpackSprite
@onready var bullet_particles: GPUParticles2D = $JetpackSprite/BulletParticles
@onready var exhaust_particles: GPUParticles2D = $JetpackSprite/ExhaustParticles
@onready var casing_particles: GPUParticles2D = $JetpackSprite/CasingParticles

var _is_dead := false

func _ready() -> void:
	hitbox.position = Vector2.ZERO
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_handle_movement(delta)
	_handle_animation()
	_apply_movement(delta)

func _handle_movement(delta: float) -> void:
	if Input.is_action_pressed("jump"):
		velocity.y -= jetpack_thrust * delta
	else:
		velocity.y += player_gravity * delta

	velocity.y = minf(velocity.y, max_velocity)

func _handle_animation() -> void:
	var is_jetpack_active := Input.is_action_pressed("jump")
	if is_jetpack_active:
		_activate_jetpack()
	else:
		_deactivate_jetpack()

func _apply_movement(delta: float) -> void:
	if move_and_collide(velocity * delta):
		velocity = Vector2.ZERO
	else:
		position.y += velocity.y * delta

func _on_hitzone_body_entered(body: Node2D) -> void:
	if _is_dead:
		return

	if body.is_in_group("hazard"):
		_handle_hazard_collision()
	elif body.is_in_group("coin"):
		_handle_coin_collision(body)

func _handle_hazard_collision() -> void:
	print("Hit hazard, game-over.")
	_is_dead = true
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
