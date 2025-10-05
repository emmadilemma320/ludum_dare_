class_name Game extends Node2D
@onready var spawn_pos: Node2D = $SpawnPos

func _ready() -> void:
	Global.spawn_pos = spawn_pos

func _process(delta: float) -> void:
	if Global.player_dead:
		get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_home_base_body_exited(body: Node2D) -> void:
	if not (body is GhostPlayer): return
	
	get_tree().call_group("item_spawn", "try_spawn")
