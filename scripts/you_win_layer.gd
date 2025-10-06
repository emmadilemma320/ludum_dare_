extends Control


func _ready():
	visible = false  # hidden at start

# When player wins:
func show_win_screen():
	visible = true
