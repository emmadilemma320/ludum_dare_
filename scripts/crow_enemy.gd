class_name CrowEnemy extends CharacterBody2D

const speed: int = 30

var dir: Vector2
var player_detected: bool
var player: CharacterBody2D

var attack_damage: int = 1
var detection_range: int = 1000

var jump_away: bool

func _ready():
	player_detected = true
	Global.enemy_crow_attack = attack_damage
	jump_away = false
	player = Global.player

func _process(delta: float) -> void:
	Global.enemy_crow_hitbox = $Hitbox
	
	if Global.player_dead:
		player_detected = false
	else:
		if position.distance_to(player.position) > detection_range:
			player_detected = false
		else:
			player_detected = true
	
	move(delta)
	animate()

func move(delta):
	if jump_away and !Global.player_dead:
		player = Global.player
		dir = position.direction_to(player.position) * -20
		velocity = dir * speed
		jump_away = false
		
	elif player_detected and !Global.player_dead:
		player = Global.player
		dir = position.direction_to(player.position)
		velocity = dir * speed
		
	# else:
		# velocity += dir * speed * delta
	move_and_slide()

func animate():
	var sprite = $AnimatedSprite2D
	if dir.x < 0: # left
		sprite.flip_h = true
	elif dir.x > 0: # right
		sprite.flip_h = false

func jump_back():
	jump_away = true

func _on_timer_timeout() -> void:
	$Timer.wait_time = rand_from([0.5, 0.8, 1.0])
	
	if !player_detected:
		dir = rand_from([Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT])

func rand_from(list):
	list.shuffle()
	return list[0]
