extends HBoxContainer

const ITEM_UI = preload("res://scenes/UI/item_ui.tscn")

func _on_timer_timeout() -> void:
	for child in get_children():
		if not (child is TextureRect): continue
		child.queue_free()
	
	for item: Item in Global.player.inventory.items:
		var item_ui = ITEM_UI.instantiate()
		item_ui.texture = item.texture
		add_child(item_ui)
