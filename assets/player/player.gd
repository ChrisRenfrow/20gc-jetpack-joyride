class_name Player
extends CharacterBody2D

## The velocity dampening to apply each bounce
const BOUNCE_DAMPENING: float = 0.5
## The threshold at which we consider the player at rest and not bouncing
const BOUNCE_THRESHOLD: float = 8.0

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

signal player_state_change(new_state: PlayerState)
## Emits when player state is HIT and bounces off floor collider
signal player_bounce(y_velocity: float)

@export_group("Positioning")
@export var home_position: Marker2D

@export_group("Movement")
@export var player_gravity: float = 500.0
@export var jetpack_thrust: float = 600.0
@export var max_velocity: float = 600.0

@export_group("Debug")
@export var invincible: bool = false

@onready var hitbox: Area2D = $Hitbox
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var jetpack_sprite: AnimatedSprite2D = $JetpackSprite
@onready var bullet_particles: GPUParticles2D = $JetpackSprite/BulletParticles
@onready var exhaust_particles: GPUParticles2D = $JetpackSprite/ExhaustParticles
@onready var casing_particles: GPUParticles2D = $JetpackSprite/CasingParticles

var _state := PlayerState.INTRO:
	set(new_state):
		player_state_change.emit(new_state)
		_state = new_state

func reset() -> void:
	_state = PlayerState.INTRO
	_setup()

func start() -> void:
	_state = PlayerState.ACTIVE
	_setup()

func _ready() -> void:
	_setup()

func _setup() -> void:
	velocity = Vector2.ZERO
	if home_position != null:
		global_position = home_position.global_position

func _physics_process(delta: float) -> void:
	_handle_movement(delta)

func _process(_delat: float) -> void:
	_handle_animation()

func _handle_movement(delta: float) -> void:
	if _state == PlayerState.ACTIVE and Input.is_action_pressed("jump"):
		velocity.y -= jetpack_thrust * delta
	else:
		velocity.y += player_gravity * delta

	velocity.y = minf(velocity.y, max_velocity)
	var maybe_collision = move_and_collide(velocity * delta)
	if maybe_collision:
		if _state == PlayerState.HIT and maybe_collision.get_collider().name == "Floor":
			velocity = -velocity * BOUNCE_DAMPENING
			player_bounce.emit(velocity.y)
			if velocity.y > -BOUNCE_THRESHOLD:
				_state = PlayerState.KO
		else:
			velocity = Vector2.ZERO
	else:
		position.y += velocity.y * delta

func _handle_animation() -> void:
	var is_jetpack_active := Input.is_action_pressed("jump")
	if is_jetpack_active and _state == PlayerState.ACTIVE:
		_activate_jetpack()
	else:
		_deactivate_jetpack()

	match _state:
		PlayerState.KO, PlayerState.HIT, PlayerState.INTRO:
			player_sprite.stop()
		PlayerState.ACTIVE:
			player_sprite.play("run")

func _on_hitzone_body_entered(body: Node2D) -> void:
	if _state != PlayerState.ACTIVE:
		return

	if body.is_in_group("hazard"):
		_handle_hazard_collision(body)
	elif body.is_in_group("coin"):
		_handle_coin_collision(body)

func _handle_hazard_collision(hazard: Node2D) -> void:
	# Missile case
	if hazard.has_method("explode"):
		hazard.explode()
		# Random push in opposite direction
		velocity.y -= clampf(velocity.y * -1, -1, 1) * randf_range(100, 200)
	else:
		# Deflect off hazard
		velocity.y *= -1
	if not invincible:
		print("Player hit hazard: ", hazard.name)
		_state = PlayerState.HIT

func _handle_coin_collision(coin: Node2D) -> void:
	coin.queue_free()
	Globals.coins += 1

func _activate_jetpack() -> void:
	Globals.jetpack_firing = true
	jetpack_sprite.play("firing")
	_set_particles_emission(true)

func _deactivate_jetpack() -> void:
	Globals.jetpack_firing = false
	jetpack_sprite.play("idle")
	_set_particles_emission(false)

func _set_particles_emission(enabled: bool) -> void:
	bullet_particles.emitting = enabled
	exhaust_particles.emitting = enabled
	casing_particles.emitting = enabled
