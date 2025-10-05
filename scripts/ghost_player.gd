class_name GhostPlayer extends CharacterBody2D

@onready var inventory: Inventory = $Inventory
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var ground_speed: float
@export var fly_speed: float
@export var gravity: float
@export var max_fall_speed: float
@export_category("flapping")
@export var flap_gravity: float
@export var flap_strength: float
@export var max_flap_velocity: float
@export_category("diving")
@export var dive_strength: float
@export var dive_gravity: float
@export var max_dive_fall_speed: float

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
	velocity.x = x_dir * get_speed()
	
	if(Input.is_action_just_pressed("flap")):
		playback.travel("flap")
		playback.start("flap", true)
		if(velocity.y < 0):
			velocity.y -= flap_strength * move_toward(1, 0, abs(min(0, velocity.y)) / max_flap_velocity)
		else:
			velocity.y = -flap_strength
	
	if(Input.is_action_just_pressed("dive") and velocity.y <= dive_strength):
		velocity.y = dive_strength
	
	velocity.y = move_toward(velocity.y, get_max_fall_speed(), get_curr_gravity() * delta)

	move_and_slide()
	check_enemy_hitbox()
	
	animate(x_dir)

func animate(x_dir):
	if(x_dir > 0): sprite.scale.x = 1
	elif(x_dir < 0): sprite.scale.x = -1
	
	sprite.rotation = 0
	
	if(is_on_floor()):
		if(velocity.x): 
			playback.travel("walk_ground")
			return
		playback.travel("idle_ground")
		return
	
	if(velocity.y > max_fall_speed + 10):
		playback.travel("dive")
		var dir = velocity.normalized()
		sprite.rotation = dir.angle() - PI / 2
		return

	if(playback.get_current_node() == "flap"):
		playback.travel("glide")
		return
		
	playback.travel("glide")

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

func get_curr_gravity() -> float:
	if(Input.is_action_pressed("dive")): 
		return dive_gravity
	if(Input.is_action_pressed("flap") and velocity.y < 0):
		return flap_gravity
	return gravity

func get_speed() -> float:
	if(is_on_floor()):
		return ground_speed
	return fly_speed

func get_max_fall_speed():
	if(Input.is_action_pressed("dive")):
		return max_dive_fall_speed
	return max_fall_speed
