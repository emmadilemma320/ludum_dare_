class_name Game extends Node2D
@onready var spawn_pos: Node2D = $SpawnPos
@onready var music_toggle: Button = $CanvasLayer/MusicToggle

@onready var heal: AudioStreamPlayer = $Heal
@onready var music: AudioStreamPlayer = $Music

@export var music_on_texture: Texture2D
@export var music_off_texture: Texture2D

var music_on: bool = true

func _ready() -> void:
	Global.spawn_pos = spawn_pos
	Global.start_pos = $StartPos.position.x
	Global.end_pos = $EndPos.position.x
	
	music_toggle.icon = music_on_texture

func _process(delta: float) -> void:
	if Global.player_dead:
		get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_home_base_body_exited(body: Node2D) -> void:
	if not (body is GhostPlayer): return
	
	get_tree().call_group("item_spawn", "try_spawn")

func _on_home_base_body_entered(body: Node2D) -> void:
	if not (body is GhostPlayer): return
	
	if(body.current_health < body.max_health):
		heal.play()
		body.current_health = body.max_health


func _on_music_finished() -> void:
	music.pitch_scale = randf_range(0.9, 1.1)

func _on_music_toggle_pressed() -> void:
	music_on = !music_on
	
	if(!music_on):
		music.stop()
		music_toggle.icon = music_off_texture
	else: 
		music.play(0)
		music_toggle.icon = music_on_texture
