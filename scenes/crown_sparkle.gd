extends ItemSparkle

func collect():
	if player.inventory.items.has(item): return
	
	player.inventory.add_item(item)
		
	if(player.inventory.is_full()): return
	
	player.peck()
	monitoring = false
	player_in_area = false
