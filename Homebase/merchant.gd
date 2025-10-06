extends Node2D

@onready var area_2d = $Area2D
@onready var label = $Label

const INTERACT_ACTION := "shop_interact"

var _current_player: Node = null
var _ui_scene: PackedScene
var _ui_instance: Control = null

func _ready():
	label.visible = false
	_ui_scene = load("res://Homebase/merchant_ui.tscn")
	
	# Keep merchant off the player's Hitbox radar:
	const INTERACT_LAYER := 1 << 7   # Layer 8
	const PLAYER_BODY_LAYER := 1 << 0 # Layer 1 (adjust if yours differs)
	
	area_2d.collision_layer = INTERACT_LAYER
	area_2d.collision_mask  = PLAYER_BODY_LAYER   # only detect bodies on L1, not Areas

	if not InputMap.has_action(INTERACT_ACTION):
		InputMap.add_action(INTERACT_ACTION)
		var ev := InputEventKey.new()
		ev.physical_keycode = KEY_Z
		InputMap.action_add_event(INTERACT_ACTION, ev)

	area_2d.body_entered.connect(_on_body_enter)
	area_2d.body_exited.connect(_on_body_exit)

func _process(delta: float) -> void:
	if (Global.player.position - position).length() > 400:
		if _ui_instance:
			_ui_instance.queue_free()

func _on_body_enter(body: Node) -> void:
	_current_player = body
	label.visible = true

func _on_body_exit(body: Node) -> void:
	if body == _current_player:
		_current_player = null
		label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if _current_player and event.is_action_pressed(INTERACT_ACTION):
		if _ui_instance:   # if shop is already open, close it
			_ui_instance.queue_free()
		else:
			_open_shop()

func _open_shop():
	if _ui_instance or not _ui_scene:
		return
	var ui := _ui_scene.instantiate()
	var inv_adapter := _current_player.get_node_or_null("InventoryAdapter")
	if inv_adapter:
		ui.set("inventory_ref", inv_adapter)
	else:
		var inv := _current_player.get_node_or_null("Inventory")
		ui.set("inventory_ref", inv)

	var ui_parent := get_tree().root
	var maybe_layer := get_tree().current_scene.get_node_or_null("UI")
	if maybe_layer:
		ui_parent = maybe_layer

	ui_parent.add_child(ui)
	_ui_instance = ui
	label.visible = false

	ui.tree_exited.connect(func ():
		_ui_instance = null
		if _current_player:
			label.visible = true)

	
