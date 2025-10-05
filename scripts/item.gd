class_name Item extends Resource

enum Rarity {RUSTED, COPPER, SILVER, GOLD}

@export var type: String
@export var rarity: Rarity
@export var texture: Texture2D

func _to_string() -> String:
	return str(rarity) + type
