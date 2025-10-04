class_name CrowEnemy extends CharacterBody2D

const speed: int = 30

var dir: Vector2
var player_detected: bool
var player: CharacterBody2D

var attack_damage: int = 5

func _ready():
	player_detected = true
	Global.enemy_crow_attack = attack_damage

func _process(delta: float) -> void:
	Global.enemy_crow_hitbox = $Hitbox
	
	move(delta)
	animate()

func move(delta):
	if player_detected:
		player = Global.player
		dir = position.direction_to(player.position)
		velocity = dir * speed
	else:
		velocity += dir * speed * delta
	move_and_slide()

func animate():
	var sprite = $AnimatedSprite2D
	if dir.x < 0: # left
		sprite.flip_h = true
	elif dir.x > 0: # right
		sprite.flip_h = false

func deal_damage():
	Global.player_health -= attack_damage

func _on_timer_timeout() -> void:
	$Timer.wait_time = rand_from([1.0, 1.5, 2.0])
	
	if ! player_detected:
		dir = rand_from([Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT])

func rand_from(list):
	list.shuffle()
	return list[0]
