extends CharacterBody2D

enum State {
	OK,
	SHOCK,
	RUN,
	KO,
}

## A vector representing the direction the minion is facing (LEFT or RIGHT)
@export var facing: Vector2 = Vector2.LEFT
## The base speed of the minion
@export var speed: float = 200
## The "run" speed of the minion
@export var run_speed: float = 300
## The range (on the x-axis) in which the minion becomes aware of the player
@export var awareness_range: float = 200
## The current game speed
@export var game_speed: float:
	get: return Globals.scroll_speed

var player: CharacterBody2D
var state: State = State.OK
var game_movement: Vector2

var shocked_duration: float = 0.5
var shocked_timer: Timer = Timer.new()

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

	shocked_timer.wait_time = shocked_duration
	shocked_timer.one_shot = true
	shocked_timer.timeout.connect(_shocked_timer_timeout)
	add_child(shocked_timer)

	if facing == Vector2.RIGHT:
		$MinionSprite.flip_h = true

func _process(delta: float) -> void:
	game_movement = Vector2(-game_speed, 0)

	match state:
		State.OK:
			if Input.is_action_pressed("jump") \
					and is_facing_player() \
					and is_in_range():
				$MinionSprite.play("shock")
				state = State.SHOCK
				shocked_timer.start()
			else:
				velocity = speed * facing
		State.SHOCK:
			velocity = Vector2.ZERO
		State.RUN:
			velocity = run_speed * facing
		State.KO:
			velocity = Vector2.ZERO

	velocity += game_movement
	position += velocity * delta

	if position.x <= -50 or position.x >= get_viewport_rect().size.x + 50:
		queue_free()

func _shocked_timer_timeout():
	$MinionSprite.flip_h = not $MinionSprite.flip_h
	facing = -facing
	$MinionSprite.play("rolling fast")
	state = State.RUN

func is_facing_player() -> bool:
	return \
	facing == Vector2.LEFT and player.position.x <= position.x or \
	facing == Vector2.RIGHT and player.position.x >= position.x

func is_in_range() -> bool:
	return absf(position.x - player.position.x) <= awareness_range

func _on_hitbox_body_entered(_body: Node2D) -> void:
	$MinionSprite.play("ko")
	state = State.KO
