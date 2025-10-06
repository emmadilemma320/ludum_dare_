extends "res://scripts/thrown_object.gd"


func _process(delta: float) -> void:
	rotation = dir.angle() + PI / 2
