class_name Game extends Node2D

@export var spawn_pos: Node2D

func _ready() -> void:
	Global.spawn_pos = spawn_pos

func _process(delta: float) -> void:
	if Global.player_dead:
		get_tree().change_scene_to_file("res://scenes/game.tscn")
