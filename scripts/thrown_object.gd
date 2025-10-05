extends Node2D

var dir: Vector2
var speed: float
var damage: int

func _physics_process(delta: float) -> void:
	position += dir * speed * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is GhostPlayer:
		body.take_damage(damage)
	
	queue_free()
