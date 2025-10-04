class_name CrowEnemy extends CharacterBody2D

const speed: int = 10

var dir: Vector2
var player_detected: bool

func _process(delta: float) -> void:
	move(delta)
	animate()

func move(delta):
	if ! player_detected:
		velocity += dir * speed * delta
	move_and_slide()

func animate():
	var sprite = $AnimatedSprite2D
	if dir.x == -1: # left
		sprite.flip_h = true
	elif dir.x == 1: # right
		sprite.flip_h = false

func _ready():
	player_detected = false

func _on_timer_timeout() -> void:
	$Timer.wait_time = rand_from([1.0, 1.5, 2.0])
	
	if ! player_detected:
		dir = rand_from([Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT])

func rand_from(list):
	list.shuffle()
	return list[0]
