extends Node2D

const THROWN_OBJECT = preload("res://scenes/thrown_object.tscn")

@onready var player: GhostPlayer = Global.player
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var throw_timer: Timer = $ThrowTimer
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

@export var max_dist: float
@export var throw_speed: float
@export var min_throw_delay: float
@export var max_throw_delay: float
@export var prediction_max_offset: float

func _ready() -> void:
	throw_timer.start(randf_range(min_throw_delay, max_throw_delay))

func _process(delta: float) -> void:
	if(player.position < position):
		scale.x = 1
	else: 
		scale.x = -1

func _on_throw_timer_timeout() -> void:
	throw_timer.start(randf_range(min_throw_delay, max_throw_delay))
	
	var to_player := player.position - position
	
	if(to_player.length() > max_dist): return
	
	var rough_time_to_reach_player = to_player.length() / throw_speed
	var target_pos = player.position + player.velocity * rough_time_to_reach_player
	
	ray_cast_2d.target_position = target_pos - position
	if ray_cast_2d.is_colliding():
		ray_cast_2d.target_position = player.position - position
		
		if(ray_cast_2d.is_colliding()): return
		sprite_2d.play("throw")
		await sprite_2d.animation_finished
		throw_at(player.position)
		sprite_2d.play("default")
		return
	
	sprite_2d.play("throw")
	await sprite_2d.animation_finished
	sprite_2d.play("default")
	throw_at(target_pos)

func throw_at(target_pos: Vector2):
	var thrown_obj = THROWN_OBJECT.instantiate()
	get_tree().root.add_child(thrown_obj)
	thrown_obj.position = position
	thrown_obj.damage = 1
	thrown_obj.dir = (target_pos - position).normalized()
	thrown_obj.speed = throw_speed
