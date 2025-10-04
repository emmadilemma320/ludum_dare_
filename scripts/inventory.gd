class_name Inventory extends Node

const INITIAL_SIZE = 10

var capacity: int = 10
var scalar: float = 1.0

var items: Array[Item] = []

func add_item(new_item: Item):
	if is_full():
		print("Inventory is full.")
	else:
		items.append(new_item)

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
