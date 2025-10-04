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
	
	print(inventory.items)

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
