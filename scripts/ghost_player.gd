class_name GhostPlayer extends CharacterBody2D

@export var speed: float
@export var gravity: float

func _physics_process(delta: float) -> void:
	var dir = Input.get_vector("left", "right", "flap", "dive")
	
	velocity = dir * speed;
	velocity += Vector2.DOWN * gravity
	move_and_slide()
