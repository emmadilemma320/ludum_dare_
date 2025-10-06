extends RichTextLabel

func _process(delta: float) -> void:
	var amt = floor(Global.player.inventory.items.size() / 5)
	if(amt == 0): 
		text = ""
		return
	text = "+" + str(amt) + " from inventory"
