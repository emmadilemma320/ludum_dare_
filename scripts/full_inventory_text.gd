extends RichTextLabel


func _process(delta: float) -> void:
	visible = Global.player.inventory.is_full()
