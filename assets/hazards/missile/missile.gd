extends StaticBody2D

## Whether the missile (during the alert phase) should follow the player
@export var homing: bool = false
## The speed at which the missile homes in on player
@export var homing_speed: float = 1000
## (if homing == true) The number of seconds to stop tracking the player prior to entering view
@export var lock_on_delay: float = 0.5
## The speed the missile travels
@export var speed: float = 1000.0
## The number of seconds to wait before starting the AlertDuration timer.
## Used for chaining multiple missiles one after the other.
@export var alert_delay: float = 0.0
## Homing marker to use for debugging purposes
@export var debug_homing_marker: Marker2D

var screen_size: Vector2
var is_delay: bool = true
var is_alert: bool = true
var homing_position: Vector2
var player: Node2D
var player_position: Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size
	player = get_tree().get_first_node_in_group("player")
	
	global_position.x = screen_size.x + 50
	
	if alert_delay > 0.001:
		$AlertDelay.stop()
		$AlertDelay.wait_time = alert_delay
		$AlertDelay.start()
	
	$AlertSprite.global_position.x = screen_size.x - 40
	$AlertSprite.hide()
	
func _physics_process(delta: float) -> void:	
	if debug_homing_marker:
		homing_position = debug_homing_marker.global_position
	elif player:
		homing_position = player.global_position
	else:
		homing_position = Vector2(0, global_position.y)
	
	if not is_alert:
		position.x -= speed * delta
	elif homing and $AlertDuration.time_left > lock_on_delay:
		var direction = (homing_position - global_position).normalized()
		position.y += homing_speed * direction.y * delta
	
	# TODO: Make it so that the missile sticks around long enough for the smoke 
	# 		trail particles to live their lives to the fullest
	if global_position.x < 0:
		print("Missile off-screen, freeing")
		queue_free()
		
func _process(delta: float) -> void:
	if $AlertDuration.time_left < lock_on_delay:
		$AlertSprite.play("critical alert")

func _on_alert_delay_timeout() -> void:
	print("Delay concluded, starting alert phase")
	is_delay = false
	$AlertSprite.show()
	$AlertSprite.play("alert")
	$AlertDuration.start()

func _on_alert_duration_timeout() -> void:
	print("Alert phase complete, missile launched")
	$AlertSprite.hide()
	$TrailParticles.emitting = true
	is_alert = false
