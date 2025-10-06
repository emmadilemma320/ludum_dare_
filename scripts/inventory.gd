class_name Inventory extends Node

const INITIAL_SIZE = 5

var capacity: int = 5
var scalar: float = 1.0

var items: Array[Item] = []

# (Optional SFX)
@onready var sfx: AudioStreamPlayer = $PickupSFX if has_node("PickupSFX") else null

@onready var inventory_adapter = %InventoryAdapter

# Preload sounds once
var sfx_item = preload("res://assets/sfx/get_item.tres")
var sfx_full = preload("res://assets/sfx/full_inventory.tres")

func add_item(new_item: Item):
	if is_full():
		_play_full()
		print("Inventory is full.")
	else:
		items.append(new_item)
		_play_item()
		inventory_adapter.update_health_bonus_from_inventory()
		
func remove_item(index: int) -> Item:
	var removed = items[index]
	items.remove_at(index)
	return removed

func get_max_capacity():
	return capacity

func is_full():
	return (len(items) == capacity)

func set_size(scalar: float):
	self.scalar = scalar
	capacity = INITIAL_SIZE * scalar

# SFX Helpers
func _play_item():
	sfx.stream = sfx_item
	sfx.play()
func _play_full():
	if(sfx.playing): return
	sfx.stream = sfx_full
	sfx.play()
