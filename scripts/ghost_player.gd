class_name GhostPlayer extends CharacterBody2D
@onready var inventory: Inventory = $Inventory
@onready var flap_timer: Timer = $FlapTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var ground_speed: float
@export var fly_speed: float
@export var rotate_speed: float
@export var dive_speed_boost: float
@export var flap_speed_boost: float
var angle: float = 10 # in deg
var target_angle: float = 10

var max_health: int = 100
var current_health: int = 100
var is_dead: bool
var is_immune: bool 

func _ready() -> void:
	Global.player = self
	is_dead = false
	Global.player_dead = false
	is_immune = false

func _physics_process(delta: float) -> void:
	var x_dir = Input.get_axis("left", "right")
	
	if(Input.is_action_just_pressed("flap")):
		angle = -30
		target_angle = -50
		flap_timer.start() 
	
	if not flapping():
		if(diving()):
			target_angle = 70
			angle = 50
		else: 
			target_angle = 10
	
	angle = move_toward(angle, target_angle, rotate_speed * delta)
	
	velocity = get_forward() * get_speed()
	velocity.x *= x_dir
	move_and_slide()
	
	if(x_dir > 0): sprite.scale.x = 1
	elif(x_dir < 0): sprite.scale.x = -1
	
	# print(inventory.items)
	
	check_enemy_hitbox()

func check_enemy_hitbox():
	var enemy_hitboxes = $Hitbox.get_overlapping_areas()
	var damage: int
	var enemy
	
	if len(enemy_hitboxes) == 0:
		return
	
	var enemy_hitbox = enemy_hitboxes[0]
	enemy = enemy_hitbox.get_parent()
	if enemy is CrowEnemy:
		damage = Global.enemy_crow_attack
	
	if !is_immune:
		take_damage(damage)
		enemy.jump_back()
		
func take_damage(damage: int):
	current_health -= damage
	print("player lost %d health. health is now %d" % [damage, current_health])
	
	if current_health <= 0:
		current_health = 0
		is_dead = true
		Global.player_dead = true
		
	immunity_cooldown(1.0)

func immunity_cooldown(seconds: int):
	is_immune = true
	await get_tree().create_timer(seconds).timeout
	is_immune = false
	
func death_animation():
	"""TODO"""

func get_speed() -> float:
	var boost = 0
	
	if(diving()): boost = dive_speed_boost
	if(flapping()): boost = flap_speed_boost
	
	if(is_on_floor()):
		return ground_speed + boost
	return fly_speed + boost

func get_forward() -> Vector2:
	return Vector2.from_angle(deg_to_rad(angle))

func flapping() -> bool:
	return flap_timer.time_left > 0

func diving() -> bool:
	return Input.is_action_pressed("dive")
