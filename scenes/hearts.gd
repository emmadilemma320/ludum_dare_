extends HBoxContainer

@export var player: GhostPlayer
const HEART = preload("res://scenes/heart.tscn")

func _process(delta: float) -> void:
	var num_hearts = get_children().size()
	var player_hearts = player.current_health
	
	for i in max(0, player_hearts - num_hearts):
		var heart = HEART.instantiate()
		add_child(heart)
	
	for i in max(0, num_hearts - player_hearts):
		get_child(num_hearts - 1 - i).queue_free()
