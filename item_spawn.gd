extends Node2D

const ITEM_SPARKLE = preload("res://scenes/item_sparkle.tscn")

const RUSTED_COIN = preload("res://items/coins/rusted_coin.tres")
const COPPER_COIN = preload("res://items/coins/copper_coin.tres")
const SILVER_COIN = preload("res://items/coins/silver_coin.tres")
const GOLD_COIN = preload("res://items/coins/gold_coin.tres")

const RUSTED_RING = preload("res://items/rings/rusted_ring.tres")
const COPPER_RING = preload("res://items/rings/copper_ring.tres")
const SILVER_RING = preload("res://items/rings/silver_ring.tres")
const GOLD_RING = preload("res://items/rings/gold_ring.tres")

const RUSTED_WATCH = preload("res://items/watches/rusted_watch.tres")
const COPPER_WATCH = preload("res://items/watches/copper_watch.tres")
const SILVER_WATCH = preload("res://items/watches/silver_watch.tres")
const GOLD_WATCH = preload("res://items/watches/gold_watch.tres")

const RUSTED_NECKLACE = preload("res://items/necklaces/rusted_necklace.tres")
const COPPER_NECKLACE = preload("res://items/necklaces/copper_necklace.tres")
const SILVER_NECKLACE = preload("res://items/necklaces/silver_necklace.tres")
const GOLD_NECKLACE = preload("res://items/necklaces/gold_necklace.tres")

static var ranges: Dictionary[Item, Vector2] = {
	RUSTED_COIN: Vector2(0, 0.2),
	RUSTED_RING: Vector2(0, 0.2),
	RUSTED_WATCH: Vector2(0, 0.2),
	RUSTED_NECKLACE: Vector2(0, 0.3),
	
	COPPER_COIN: Vector2(0.2, 0.4),
	COPPER_RING: Vector2(0.2, 0.45),
	COPPER_WATCH: Vector2(0.25, 0.5),
	COPPER_NECKLACE: Vector2(0.3, 0.6),
	
	SILVER_COIN: Vector2(0.3, 0.8),
	SILVER_RING: Vector2(0.5, 0.8),
	SILVER_WATCH: Vector2(0.6, 0.9),
	SILVER_NECKLACE: Vector2(0.6, 0.9),
	
	GOLD_COIN: Vector2(0.5, 1),
	GOLD_RING: Vector2(0.7, 1),
	GOLD_WATCH: Vector2(0.75, 1),
	GOLD_NECKLACE: Vector2(0.8, 1),
}
static var spawn_chance: float = 0.5
var obj: ItemSparkle

func try_spawn():
	if(obj != null and is_instance_valid(obj)):
		obj.queue_free()
		obj = null;
	
	if(randf() >= spawn_chance): 
		print("nope!")
		return
	
	var sparkle = ITEM_SPARKLE.instantiate()
	sparkle.item = pick_item(position)
	obj = sparkle
	sparkle.position = position
	
	await get_tree().process_frame
	
	get_tree().root.add_child(sparkle)
	sparkle.state = sparkle.States.keys()[randi() % sparkle.States.size()]
	print(sparkle.item)

static func pick_item(pos: Vector2) -> Item:
	var dist:float = (pos.x - Global.start_pos) / (Global.end_pos - Global.start_pos)
	
	return get_item_choices_at_percent(dist).pick_random()

static func get_item_choices_at_percent(percent: float) -> Array[Item]:
	var array: Array[Item] = []
	for key in ranges.keys():
		var vector = ranges[key]
		if(percent > vector.x and percent < vector.y): 
			array.append(key)
	
	return array
