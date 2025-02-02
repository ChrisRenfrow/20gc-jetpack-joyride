class_name Laser
extends StaticBody2D

enum LaserState {
	DELAY_ENTER,
	ENTER,
	DELAY_CHARGE,
	CHARGING,
	FIRING,
	EXIT
}

const DIODE_MARGIN: float = 20.0
const DIODE_OFFSET: float = 80.0
const BEAM_OFFSET: float = 150.0
const POSITION_THRESHOLD: float = 2.0

@export_group("Movement")
## The speed at which the diodes move in and out of view
@export var move_speed: float = 5
## The easing factor to apply to movement
@export var easing_factor: float = 1

@export_group("Timing")
## The time in seconds to delay entering the view
@export var enter_delay: float = 0.001
## The time in seconds to delay charging the laser
@export var charge_delay: float = 0.001
## The time in seconds spent charging the laser
@export var charge_time: float = 2
## The time in seconds spent firing the laser
@export var fire_time: float = 3

var _screen_size: Vector2
var _state = LaserState.DELAY_ENTER
var _diode_a_target_pos: Vector2
var _diode_b_target_pos: Vector2
var _enter_delay_timer := Timer.new()
var _charge_delay_timer := Timer.new()

@onready var _charge_timer: Timer = $ChargeTime
@onready var _fire_timer: Timer = $FireTime
@onready var _laser_shape: CollisionShape2D = $LaserShape
@onready var _diode_a: AnimatedSprite2D = $DiodeA
@onready var _diode_b: AnimatedSprite2D = $DiodeB
@onready var _beam: Node2D = $Beam
@onready var _beam_sprite: Sprite2D = $Beam/BeamSprite
@onready var _beam_charging_sprite: Sprite2D = $Beam/BeamChargingSprite

func _ready() -> void:
	_screen_size = get_viewport_rect().size

	_setup_positions()
	_setup_timers()

	_laser_shape.disabled = true
	_beam_sprite.hide()
	_beam_charging_sprite.hide()


func _process(delta: float) -> void:
	match _state:
		LaserState.ENTER:
			if _move_diodes(delta, _diode_a_target_pos, _diode_b_target_pos):
				_state = LaserState.DELAY_CHARGE
				_charge_delay_timer.start()
		LaserState.EXIT:
			if _move_diodes(
					delta,
					Vector2(-20, _diode_a_target_pos.y),
					Vector2(_screen_size.x + 20, _diode_b_target_pos.y)
				):
				print("Laser diodes off-screen, freeing")
				queue_free()

func _change_state(new_state: LaserState) -> void:
	_state = new_state
	prints("Changing state:", LaserState.keys()[new_state])
	match _state:
		LaserState.CHARGING:
			_play_diode_animation("charging")
			_beam_charging_sprite.show()
			_charge_timer.start()
		LaserState.FIRING:
			_play_diode_animation("firing")
			_beam_charging_sprite.hide()
			_beam_sprite.show()
			_fire_timer.start()
			_laser_shape.disabled = false
		LaserState.EXIT:
			_play_diode_animation("idle")
			_beam_sprite.hide()
			_laser_shape.disabled = true


func _setup_positions() -> void:
	position.x = 0
	# Calculate diode position endpoints
	_diode_a_target_pos = Vector2(DIODE_MARGIN, _diode_a.position.y)
	_diode_b_target_pos = Vector2(_screen_size.x - DIODE_MARGIN, _diode_b.position.y)
	# Set diode positions off-screen
	_diode_a.position.x = _diode_a_target_pos.x - DIODE_OFFSET
	_diode_b.position.x = _diode_b_target_pos.x + DIODE_OFFSET
	# Set beam length and position
	_beam_sprite.region_rect.size.x = _diode_b_target_pos.x - _diode_a_target_pos.x
	_beam_charging_sprite.region_rect.size.x = _diode_b_target_pos.x - _diode_a_target_pos.x
	_beam.position.x = _screen_size.x / 2
	# Set collider length and position
	_laser_shape.shape.size.x = _diode_b_target_pos.x - _diode_a_target_pos.x
	_laser_shape.position.x = _screen_size.x / 2

func _setup_timers() -> void:
	# TODO: Make the use of timers consistent, either use Nodes or just set them up internally like this
	_enter_delay_timer.wait_time = enter_delay
	_enter_delay_timer.one_shot = true
	_enter_delay_timer.autostart = true
	_enter_delay_timer.timeout.connect(_on_enter_delay_timeout)
	add_child(_enter_delay_timer)

	_charge_delay_timer.wait_time = charge_delay
	_charge_delay_timer.one_shot = true
	_charge_delay_timer.timeout.connect(_on_charge_delay_timeout)
	add_child(_charge_delay_timer)

	_charge_timer.wait_time = charge_time
	_fire_timer.wait_time = fire_time

func _move_diodes(delta: float, a_target_pos: Vector2, b_target_pos: Vector2) -> bool:
	for diode in [_diode_a, _diode_b]:
		var target = a_target_pos if diode == _diode_a else b_target_pos
		diode.position = diode.position.lerp(
			target,
			easing_factor * delta * move_speed
		)
		if diode.position.distance_to(target) < POSITION_THRESHOLD:
			diode.position = target

	return _diode_a.position == a_target_pos and _diode_b.position == b_target_pos

func _play_diode_animation(animation: String) -> void:
	_diode_a.play(animation)
	_diode_b.play(animation)

func _on_enter_delay_timeout() -> void:
	_change_state(LaserState.ENTER)

func _on_charge_delay_timeout() -> void:
	_change_state(LaserState.CHARGING)

func _on_charge_time_timeout() -> void:
	_change_state(LaserState.FIRING)

func _on_fire_time_timeout() -> void:
	_change_state(LaserState.EXIT)
