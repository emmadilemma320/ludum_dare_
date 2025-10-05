extends Node
class_name HBS_InventoryAdapter

# Link to your teammate's Inventory node (typed export!)
@export var inventory: Inventory

# Optional price lookup if items don't carry price
@export var price_map := {}  # e.g. {"wood": 2, "iron": 5}

# (Optional) reference to player if upgrades modify stats (e.g. speed)
@export var player: Node

# Internal fallback for owned upgrades (until team adds real upgrade storage)
var _owned_upgrades := {}

# ---- Shop API expected by your MerchantUI / ShopService ----
# Returns: Array of {id:String, qty:int, unit_value:int}
func get_sellables() -> Array:
	if inventory == null:
		return []

	# Your inventory is a flat array of "items"
	# We group identical items by id and count them
	var counts := {}
	var prices := {}

	for it in inventory.items:
		var id := _get_item_id(it)
		if id == "":
			continue

		counts[id] = int(counts.get(id, 0)) + 1

		if not prices.has(id):
			var p := _get_item_price(it, id)
			prices[id] = p

	var out: Array = []
	for id in counts.keys():
		out.append({
			"id": id,
			"qty": counts[id],
			"unit_value": int(prices.get(id, 0)),
		})
	return out


# Remove 'qty' copies of a specific id
func remove_amount(item_id: String, qty: int) -> void:
	if inventory == null or qty <= 0:
		return
	var remaining := qty

	# remove from the end to avoid reindexing surprises
	for i in range(inventory.items.size() - 1, -1, -1):
		if remaining <= 0:
			break
		var it = inventory.items[i]
		if _get_item_id(it) == item_id:
			inventory.remove_item(i)   # uses teammate's API
			remaining -= 1

# Remove all items for these ids (used by sell_all)
func remove_sold(ids: Array) -> void:
	if inventory == null:
		return
	var idset := ids.duplicate()
	for i in range(inventory.items.size() - 1, -1, -1):
		var it = inventory.items[i]
		if _get_item_id(it) in idset:
			inventory.remove_item(i)

# Upgrades
func has_upgrade(id: String) -> bool:
	return bool(_owned_upgrades.get(id, false))

func add_upgrade(id: String) -> void:
	_owned_upgrades[id] = true
	# Example: apply gameplay effects
	# Triggered when buying +50 speed upgrade
	if id == "upgrade_b" and player:
		_apply_speed_bonus(50)
	if id == "upgrade_a" and player:
		__apply_health_bonus(20)
			
# ---- helpers ----
func _get_item_id(it) -> String:
	# accept dictionary or object items
	if typeof(it) == TYPE_DICTIONARY:
		return String(it.get("id", ""))
	if typeof(it) == TYPE_OBJECT:
		if it.has_variable("id"):
			return String(it.id)
		if it.has_method("get_id"):
			return String(it.get_id())
	return ""

func _get_item_price(it, id: String) -> int:
	if typeof(it) == TYPE_DICTIONARY:
		if it.has("price"): return int(it["price"])
	elif typeof(it) == TYPE_OBJECT:
		if it.has_variable("price"): return int(it.price)
		if it.has_method("get_price"): return int(it.get_price())

	# fallback: lookup in price_map
	return int(price_map.get(id, 0))
# Upgrade: +50 fly speed		
func _apply_speed_bonus(amount: int) -> void:
	var candidates := ["fly_speed"]
	for prop in candidates:
		var val = player.get(prop)
		if typeof(val) == TYPE_INT or typeof(val) == TYPE_FLOAT:
			player.set(prop, val + amount)
			print("Speed up! New %s = %s" % [prop, player.get(prop)])
			return
func __apply_health_bonus(amount: int) -> void:
	var candidates := ["max_health"]
	for prop in candidates:
		var val = player.get(prop)
		if typeof(val) == TYPE_INT or typeof(val) == TYPE_FLOAT:
			player.set(prop, val + amount)
			print("Health up! New %s = %s" % [prop, player.get(prop)])
			return
func _ready():
	if player == null and get_parent() != null:
		player = get_parent()
	
