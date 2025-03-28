class_name Missile extends Hazard

enum MissileState {
    DELAY,
    ALERT,
    ACTIVE,
    BOOM,
    OFF_SCREEN,
}

@export_group("Homing")
## Whether the missile (during the alert phase) should follow the player.
@export var homing: bool = false
## The speed at which the missile homes in on player.
@export var homing_speed: float = 1000
## (if homing == true) The number of seconds to stop tracking the player prior to entering view.
@export var lock_on_delay: float = 0.5

@export_group("Movement")
## The speed the missile travels.
@export var speed: float = 1000.0
## The number of seconds to wait before starting the AlertDuration timer.
## Used for chaining multiple missiles one after the other.
@export var alert_delay: float = 0.001

@export_group("Debug")
## Homing marker to use for debugging purposes.
@export var homing_marker: Marker2D
## Show homing targeting vector as a line.
## Good for debugging the target's origin.
@export var show_homing_vector: bool = false

var _screen_size: Vector2
var _player: Node2D
var _state: MissileState = MissileState.DELAY
var _homing_position: Vector2

@onready var missile_sprite: AnimatedSprite2D = $MissileSprite
@onready var missile_shape: CollisionShape2D = $MissileShape
@onready var alert_sprite: AnimatedSprite2D = $AlertSprite
@onready var trail_particles: GPUParticles2D = $TrailParticles
@onready var alert_delay_timer: Timer = $AlertDelay
@onready var alert_duration_timer: Timer = $AlertDuration
@onready var explosion: Node2D = $Explosion

## Stops the missile and plays exploding animation/particles before despawning
func explode() -> void:
	_state = MissileState.BOOM
	missile_sprite.hide()
	missile_shape.set_deferred("disabled", true)
	trail_particles.emitting = false
	explosion.explode()
	await get_tree().create_timer(2).timeout
	queue_free()

func _init(t=HazardType.MISSILE) -> void:
	super(t)

func _ready() -> void:
	_init_missile()
	_setup_alert_delay()

func _draw() -> void:
	if show_homing_vector and homing and _state == MissileState.ALERT:
		draw_line(Vector2.ZERO, _homing_position - global_position, Color.RED)

func _physics_process(delta: float) -> void:
	_update_homing_position()
	queue_redraw()

	match _state:
		MissileState.ACTIVE, MissileState.OFF_SCREEN:
			position.x -= speed * delta
		MissileState.ALERT:
			if not homing or alert_duration_timer.time_left <= lock_on_delay:
				return
			var direction := (_homing_position - global_position).normalized()
			position.y += homing_speed * direction.y * delta

	_check_bounds()

func _process(_delta: float) -> void:
	if _state == MissileState.ALERT and alert_duration_timer.time_left < lock_on_delay:
		alert_sprite.play("critical alert")

func _init_missile() -> void:
	_screen_size = get_viewport_rect().size
	_player = get_tree().get_first_node_in_group("player")
	$MissileShape.disabled = true
	global_position.x = _screen_size.x + 50
	alert_sprite.global_position.x = _screen_size.x - 40
	alert_sprite.hide()
	# Doesn't actually get triggered until one-shot is enabled and the cycle finishes
	trail_particles.finished.connect(_on_trail_particles_finished)

func _setup_alert_delay() -> void:
	if alert_delay > 0.001:
		alert_delay_timer.stop()
		alert_delay_timer.wait_time = alert_delay
		alert_delay_timer.start()
	else:
		_start_alert_phase()

func _update_homing_position() -> void:
	if homing_marker:
		_homing_position = homing_marker.global_position
	elif _player:
		_homing_position = _player.global_position
	else:
		_homing_position = Vector2(0, position.y)

func _check_bounds() -> void:
	if global_position.x < -20 and _state != MissileState.OFF_SCREEN:
		print("Missile off-screen, waiting for particles to finish")
		_state = MissileState.OFF_SCREEN
		trail_particles.emitting = false
		trail_particles.one_shot = true
		trail_particles.emitting = true

func _start_alert_phase() -> void:
	print("Delay concluded, starting alert phase")
	_state = MissileState.ALERT
	alert_sprite.show()
	alert_sprite.play("alert")
	alert_duration_timer.start()

func _on_alert_delay_timeout() -> void:
	_start_alert_phase()

func _on_alert_duration_timeout() -> void:
	print("Alert phase complete, missile launched")
	_state = MissileState.ACTIVE
	alert_sprite.hide()
	trail_particles.emitting = true
	$MissileShape.disabled = false

func _on_trail_particles_finished() -> void:
	print("Particles finished, freeing")
	queue_free()
