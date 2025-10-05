extends Control

# Set by Merchant.gd when opening
@export var inventory_ref: Node

# ---------- LEFT PANEL (under Panel) ----------
@onready var title_label: Label = $Panel/LeftVBox/Label
@onready var upgrades_vbox: VBoxContainer = $Panel/LeftVBox/ScrollContainer/UpgradesVBox

# ---------- RIGHT PANEL (under PanelPlayer) ----------
@onready var items_vbox: VBoxContainer = $PanelPlayer/VBoxContainer/ScrollContainer/ItemsVBox
@onready var sell_all_items_btn: Button = $PanelPlayer/VBoxContainer/HBoxContainer/Label/ButtonSellAllItems

# (Optional SFX)
@onready var sfx: AudioStreamPlayer = $SfxPlayer if has_node("SfxPlayer") else null

# Merchant catalog (edit freely)
# Add rows: 
# { "id": Upgrade Id, "icon": "res://Homebase/upgrade_a.png", "label": Upgrade Name, "price": coins needed"
# Then apply necessary functions in HBS_InventoryAdapter.gd
# ----- Font you want to use -----
var _font: FontFile = preload("res://Homebase/tiny.ttf")  # <-- change path
var _font_size := 12  # pick what you want (8–12 usually looks clean)

var UPGRADE_DEFS := [
	{ "id": "upgrade_a", "icon": "res://Homebase/icon.png", "label": "+20 Health", "price": 50 },
	{ "id": "upgrade_b", "icon": "res://Homebase/icon.png", "label": "+50 Speed", "price": 120 },
]
	
func _style_label(lbl: Label):
	lbl.add_theme_font_override("font", _font)
	lbl.add_theme_font_size_override("font_size", _font_size)
	
func _style_button(btn: Button, w := 30, h := 16) -> void:
	btn.add_theme_font_override("font", _font)
	btn.add_theme_font_size_override("font_size", _font_size)
	btn.custom_minimum_size = Vector2(w, h)
	
func _ready():
	_style_label(title_label)
	if has_node("PanelPlayer"):
		_style_button(sell_all_items_btn, 30, 16)
	# RIGHT: buttons
	sell_all_items_btn.pressed.connect(_on_sell_all_items_global)

	# Build both panels
	_refresh_title()
	_build_upgrades()
	_build_inventory()

	# Refresh on wallet/shop changes
	HbsWallet.balance_changed.connect(_on_balance_changed)
	HbsShopService.sell_succeeded.connect(func(_amt:int):
		_refresh_title()
		_build_inventory()
	)
	HbsShopService.purchase_succeeded.connect(func(_id:String):
		_refresh_title()
		_build_upgrades()
	)
	HbsShopService.purchase_failed.connect(func(_reason:String):
		_refresh_title()
		_build_upgrades()
	)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		queue_free()

# ---------------- Title / wallet ----------------
func _on_balance_changed(_new := 0) -> void:
	_refresh_title()
	_build_upgrades()

func _refresh_title(_n := 0) -> void:
	title_label.text = "Coins Collected: %d" % HbsWallet.get_balance()

# ---------------- Actions ----------------
func _on_sell_all_items_global() -> void:
	if inventory_ref:
		HbsShopService.sell_all(inventory_ref)

func _try_buy_upgrade(id: String, price: int) -> void:
	if not inventory_ref:
		HbsShopService.purchase_failed.emit("No inventory.")
		return
	HbsShopService.buy_upgrade(inventory_ref, id, price)

# ---------------- LEFT: build upgrades (scrollable) ----------------
func _build_upgrades():
	for c in upgrades_vbox.get_children():
		c.queue_free()

	var coins := HbsWallet.get_balance()
	var already_has := func(id: String) -> bool:
		return inventory_ref \
			and inventory_ref.has_method("has_upgrade") \
			and inventory_ref.has_upgrade(id)

	for def in UPGRADE_DEFS:
		var id := String(def.get("id", ""))
		var label := String(def.get("label", id))
		var price := int(def.get("price", 0))
		var icon_path := String(def.get("icon", ""))

		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 30)

		# Optional icon
		if icon_path != "":
			var icon_rect := TextureRect.new()
			icon_rect.custom_minimum_size = Vector2(24, 24)
			icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			var tex = load(icon_path)
			if tex: icon_rect.texture = tex
			row.add_child(icon_rect)

		var name_lbl := Label.new()
		_style_label(name_lbl)
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.text = label
		row.add_child(name_lbl)

		var price_lbl := Label.new()
		_style_label(price_lbl)
		price_lbl.custom_minimum_size = Vector2(60, 0)
		price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		price_lbl.text = "%d" % price
		row.add_child(price_lbl)

		var buy_btn := Button.new()
		_style_button(buy_btn, 30, 16)
		buy_btn.text = "Buy"
		var owned: bool = bool(already_has.call(id))
		buy_btn.disabled = owned or (coins < price)
		buy_btn.pressed.connect(func(): _try_buy_upgrade(id, price))
		row.add_child(buy_btn)

		if owned:
			buy_btn.text = "Own"

		upgrades_vbox.add_child(row)

# ---------------- RIGHT: build inventory (scrollable) ----------------
func _build_inventory():
	for c in items_vbox.get_children():
		c.queue_free()

	var items: Array = []
	if inventory_ref and inventory_ref.has_method("get_sellables"):
		items = inventory_ref.get_sellables()

	if items.is_empty():
		var empty := Label.new()
		_style_label(empty)
		empty.text = "No items in inventory."
		items_vbox.add_child(empty)
		return

	for it in items:
		var id := String(it.get("id",""))
		var qty := int(it.get("qty", 0))
		var unit := int(it.get("unit_value", 0))
		var total := qty * unit

		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 28)

		var name_lbl := Label.new()
		_style_label(name_lbl)
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.text = id
		row.add_child(name_lbl)

		var qty_lbl := Label.new()
		_style_label(qty_lbl)
		qty_lbl.custom_minimum_size = Vector2(70, 0)
		qty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		qty_lbl.text = "x%d" % qty
		row.add_child(qty_lbl)

		var price_lbl := Label.new()
		_style_label(price_lbl)
		price_lbl.custom_minimum_size = Vector2(130, 0)
		price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		price_lbl.text = "@ %d (= %d)" % [unit, total]
		row.add_child(price_lbl)

		var sell1 := Button.new()
		_style_button(sell1, 30, 16)
		sell1.text = "Sell 1"
		sell1.disabled = qty <= 0
		sell1.pressed.connect(func(): _sell_item(id, 1))
		row.add_child(sell1)

		var sell_all := Button.new()
		_style_button(sell_all, 30, 16)
		sell_all.text = "Sell All"
		sell_all.disabled = qty <= 0
		sell_all.pressed.connect(func(): _sell_item(id, qty))
		row.add_child(sell_all)

		items_vbox.add_child(row)

func _sell_item(id: String, n: int) -> void:
	if inventory_ref:
		HbsShopService.sell_item(inventory_ref, id, n)
