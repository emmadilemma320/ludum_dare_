extends Control

@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	visible = false  # hidden at start
	quit_button.pressed.connect(_on_quit_pressed)

# When player wins:
func show_win_screen():
	visible = true

func _on_quit_pressed():
	get_tree().quit()
