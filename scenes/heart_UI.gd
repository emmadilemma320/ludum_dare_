extends TextureRect

@export var filled_texture: Texture2D
@export var empty_texture: Texture2D

var is_filled: bool:
	set(value):
		is_filled = value
		
		if(value): texture = filled_texture
		else: texture = empty_texture
