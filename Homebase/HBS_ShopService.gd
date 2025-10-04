extends Node
class_name HBS_ShopService

signal purchase_succeeded(upgrade_id: String)
signal purchase_failed(reason: String)
signal sell_succeeded(total_earned: int)

# --------------------------------------------------------------
# inventory.get_sellables() -> Array of dictionaries:
#   [{ "id": String, "qty": int, "unit_value": int }, ...]
# inventory.remove_sold(ids: Array[String]) -> void
# inventory.has_upgrade(id: String) -> bool
# inventory.add_upgrade(id: String) -> void
# ---------------------------------------------------------------

func sell_all(inventory: Node) -> void:
	if inventory == null or not inventory.has_method("get_sellables"):
		return
	var items = inventory.get_sellables()
	var total := 0
	var sold_ids: Array[String] = []
	for it in items:
		var id := String(it.get("id", ""))
		var qty := int(it.get("qty", 0))
		var unit_value := int(it.get("unit_value", 0))
		if id == "" or qty <= 0 or unit_value < 0:
			continue
		total += qty * unit_value
		sold_ids.append(id)
	if total > 0:
		HbsWallet.add(total)
		if inventory.has_method("remove_sold"):
			inventory.remove_sold(sold_ids)
	sell_succeeded.emit(total)

func buy_upgrade(inventory: Node, upgrade_id: String, price: int) -> void:
	if upgrade_id.is_empty():
		purchase_failed.emit("Invalid upgrade.")
		return
	if inventory == null:
		purchase_failed.emit("No inventory.")
		return
	if inventory.has_method("has_upgrade") and inventory.has_upgrade(upgrade_id):
		purchase_failed.emit("Already owned.")
		return
	if HbsWallet.try_spend(price):
		if inventory.has_method("add_upgrade"):
			inventory.add_upgrade(upgrade_id)
		purchase_succeeded.emit(upgrade_id)
	else:
		purchase_failed.emit("Not enough coins.")
