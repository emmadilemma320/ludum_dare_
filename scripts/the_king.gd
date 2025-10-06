# the_king.gd
extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D

const ACTION := "king_change"

var _player_in_range := false
var _has_changed := false   # prevent multiple triggers

func _ready() -> void:
	if not InputMap.has_action(ACTION):
		InputMap.add_action(ACTION)
		var ev := InputEventKey.new()
		ev.physical_keycode = KEY_C
		InputMap.action_add_event(ACTION, ev)

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	# Start on the default animation
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("crown"):
		sprite.play("crown")

func _on_body_entered(body: Node) -> void:
	if body is GhostPlayer:
		_player_in_range = true

func _on_body_exited(body: Node) -> void:
	if body is GhostPlayer:
		_player_in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range and event.is_action_pressed(ACTION):
		if not _has_changed:
			_change_sprite()

func _change_sprite() -> void:
	_has_changed = true
	sprite.play("nocrown")
