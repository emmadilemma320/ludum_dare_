extends Node
class_name HBS_InventoryAdapter

@export var inventory: Inventory
@export var player: Node
@export var price_map := {}  # still supported as a fallback for non-Item data

const ItemSpawn = preload("res://scripts/item_spawn.gd")

var _owned_upgrades := {}

# ---- Pricing rules for Item resources ----
const BASE_PRICE_BY_TYPE := {
	"coin": 1,
	"watch": 3,
	"necklace": 5,
	"ring": 7,
	"crown": 12500,
}
const RARITY_NAMES := ["rusted", "copper", "silver", "gold"]  # index = enum value
static func _rarity_multiplier(idx: int) -> int:
	# 2^idx => rusted=1, copper=2, silver=4, gold=8
	return 1 << max(idx, 0)

func _item_id(it: Item) -> String:
	var t := (it.type if it.type != null else "").to_lower()
	var idx := int(it.rarity)
	var rname := "unknown"
	if idx >= 0 and idx < RARITY_NAMES.size():
		rname = RARITY_NAMES[idx]
	return "%s_%s" % [t, rname]

func _item_price(it: Item) -> int:
	var t := (it.type if it.type != null else "").to_lower()
	var base := int(BASE_PRICE_BY_TYPE.get(t, 0))
	var mult := _rarity_multiplier(int(it.rarity))
	return base * mult

# ---- Shop API ----
func get_sellables() -> Array:
	var inv := _ensure_inventory()
	if inv == null:
		return []

	var counts := {}
	var prices := {}
	var icons := {}   # id -> Texture2D

	for it in inv.items:
		# inventory is Array[Item]; guard for safety
		if typeof(it) == TYPE_OBJECT and it is Item:
			var id := _item_id(it)
			counts[id] = int(counts.get(id, 0)) + 1
			if not prices.has(id):
				prices[id] = _item_price(it)
			# remember one icon per id (first seen)
			if not icons.has(id) and it.texture:
				icons[id] = it.texture
		elif typeof(it) == TYPE_DICTIONARY:
			var id := String(it.get_or_default("id", ""))
			if id == "":
				continue
			counts[id] = int(counts.get(id, 0)) + 1
			if not prices.has(id):
				prices[id] = int(it.get_or_default("price", price_map.get(id, 0)))
		else:
			# Unknown shape; try price_map by stringified id
			var id := str(it)
			counts[id] = int(counts.get(id, 0)) + 1
			if not prices.has(id):
				prices[id] = int(price_map.get(id, 0))

	var out: Array = []
	for id in counts.keys():
		out.append({
			"id": id,
			"qty": counts[id],
			"unit_value": int(prices.get(id, 0)),
			"icon": icons.get(id, null),
		})
	return out

func remove_amount(item_id: String, qty: int) -> void:
	if qty <= 0: return
	var inv := _ensure_inventory()
	if inv == null: return
	var remaining := qty
	# Remove from end to avoid reindex shifts
	for i in range(inv.items.size() - 1, -1, -1):
		if remaining <= 0: break
		var it = inv.items[i]
		if typeof(it) == TYPE_OBJECT and it is Item:
			if _item_id(it) == item_id:
				inv.remove_item(i)
				remaining -= 1
		elif typeof(it) == TYPE_DICTIONARY:
			if String(it.get_or_default("id","")) == item_id:
				inv.remove_item(i)
				remaining -= 1
		else:
			if String(it) == item_id:
				inv.remove_item(i)
				remaining -= 1
	update_health_bonus_from_inventory()

func remove_sold(ids: Array) -> void:
	var inv := _ensure_inventory()
	if inv == null: return
	var idset := {}
	for id in ids: idset[id] = true
	for i in range(inv.items.size() - 1, -1, -1):
		var it = inv.items[i]
		var curr_id := ""
		if typeof(it) == TYPE_OBJECT and it is Item:
			curr_id = _item_id(it)
		elif typeof(it) == TYPE_DICTIONARY:
			curr_id = String(it.get_or_default("id",""))
		else:
			curr_id = String(it)
		if curr_id in idset:
			inv.remove_item(i)
	update_health_bonus_from_inventory()

# ---- Upgrades ----
func has_upgrade(id: String) -> bool:
	return bool(_owned_upgrades.get(id, false))

func add_upgrade(id: String) -> void:
	_owned_upgrades[id] = true
	if not is_instance_valid(player): return

	if id == "upgrade_b": _apply_speed_bonus(50)
	if id == "upgrade_a": __apply_health_bonus(2)
	if id == "upgrade_c": __apply_dive_bonus(80)
	if id == "upgrade_d": __apply_flap_bonus(20)
	if id == "upgrade_e": __apply_hover_bonus(-10)
	if id == "upgrade_f": __apply_inventory_bonus(10)
	if id == "upgrade_g": __apply_luck_bonus(0.4)

func _apply_speed_bonus(amount: int) -> void:
	# If add_speed(), prefer that
	if player.has_method("add_speed"):
		player.add_speed(amount)
		print("Speed up! ground=%s fly=%s" % [player.get("ground_speed"), player.get("fly_speed")])
		return
	# Otherwise set common props directly
	for prop in ["ground_speed", "fly_speed", "speed"]:
		var v = player.get(prop)
		if typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT:
			player.set(prop, v + amount)
	print("Speed up! ground=%s fly=%s" % [player.get("ground_speed"), player.get("fly_speed")])

func __apply_health_bonus(amount: int) -> void:
	for prop in ["max_health"]:
		var v = player.get(prop)
		if typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT:
			player.set(prop, v + amount)
	print("Health up! max_health=%s" % [player.get("max_health")])

func __apply_dive_bonus(amount: int) -> void:
	for prop in ["dive_strength"]:
		var v = player.get(prop)
		if typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT:
			player.set(prop, v + amount)
	print("Dive strength up! %s" % [player.get("dive_strength")])

func __apply_flap_bonus(amount: int) -> void:
	for prop in ["flap_strength"]:
		var v = player.get(prop)
		if typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT:
			player.set(prop, v + amount)
	print("Flap strength up! %s" % [player.get("flap_strength")])

func __apply_hover_bonus(amount: int) -> void:
	for prop in ["gravity"]:
		var v = player.get(prop)
		if typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT:
			player.set(prop, v + amount)
	print("Hover time up! gravity=%s" % [player.get("gravity")])

func __apply_inventory_bonus(amount: int) -> void:
	for prop in ["capacity"]:
		var v = inventory.get(prop)
		if typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT:
			inventory.set(prop, v + amount)
	print("Inventory capaity up!" % [inventory.get("capaity")])
	
func __apply_luck_bonus(amount: int) -> void:
	ItemSpawn.spawn_chance += amount
	print("Item spawn rate up!" % [ItemSpawn.spawn_chance])

# ------------------------------------------------------------------
# Recalculate +1 max_health per 5 carried items
# ------------------------------------------------------------------
func update_health_bonus_from_inventory() -> void:
	var count = inventory.items.size()
	var bonus = int(count / 5)  # 1 health per 5 items

	# Store and update only when changed
	if not player.has_meta("item_health_bonus"):
		player.set_meta("item_health_bonus", 0)

	var prev_bonus = player.get_meta("item_health_bonus")
	if prev_bonus != bonus:
		# Remove previous bonus
		for prop in ["max_health"]:
			var v = player.get(prop)
			if typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT:
				player.set(prop, v - prev_bonus + bonus)
		player.set_meta("item_health_bonus", bonus)
		print("Inventory bonus updated: +%d max health (total = %d items)" % [bonus, count])
	_ensure_inventory()

# Try to find/remember the Inventory node
func _ensure_inventory() -> Inventory:
	if inventory != null:
		return inventory
	var p := get_parent()
	if p != null:
		var n := p.get_node_or_null("Inventory")
		if n != null and n is Inventory:
			inventory = n
			return inventory
	return null
func _ready() -> void:
	# Auto-wire player if adapter is a child of the player
	if player == null and get_parent() != null:
		player = get_parent()
		_ensure_inventory()
