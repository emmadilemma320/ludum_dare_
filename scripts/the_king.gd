# the_king.gd
extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var item_sparkle: Area2D = $ItemSparkle

func _process(delta: float) -> void:
	if Global.player.inventory.items.has(item_sparkle.item):
		if(sprite.animation == "nocrown"): return
		sprite.play("nocrown")
		return
	
	sprite.play("crown")
