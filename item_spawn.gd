extends Node2D

const ITEM_SPARKLE = preload("res://scenes/item_sparkle.tscn")

@export var spawn_chances: Dictionary[float, Item]
@export var spawn_chance: float
var obj: ItemSparkle

func try_spawn():
	if(obj != null and is_instance_valid(obj)):
		obj.queue_free()
		obj = null;
	
	if(randf() >= spawn_chance): 
		print("nope!")
		return
	
	var sparkle = ITEM_SPARKLE.instantiate()
	sparkle.item = pick_item()
	obj = sparkle
	sparkle.position = position
	
	await get_tree().process_frame
	
	get_tree().root.add_child(sparkle)
	sparkle.state = sparkle.States.keys()[randi() % sparkle.States.size()]
	print(sparkle.item)

func pick_item() -> Item:
	var val = randf()
	
	var last_key = 0
	var chances: Array[float] = spawn_chances.keys()
	chances.sort()
	
	for key in chances:
		if(key > val): break
		
		last_key = key
	
	return spawn_chances[last_key]
