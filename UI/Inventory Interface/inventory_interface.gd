class_name InventoryInterface
extends Control

signal inventory_updated

@export var inventory: Array[ItemData] = []  # Holds references to ItemData resources
@export var rows: int = 3
@export var columns: int = 3

@onready var grid = $NinePatchRect/GridContainer  # Reference to GridContainer
@onready var slots = []  # For buttons
@onready var inv_background = $NinePatchRect

var def_slot_icon = preload("res://UI/temp_png/inventory-slot.png")
var item_icons: Dictionary = {}

func _ready():
	preload_item_icons()
	print("Initializing InventoryInterface...")
	# Fill slots with buttons
	for child in grid.get_children():
		if child is Button:
			child.custom_minimum_size = Vector2(25, 25)
	for i in range(grid.get_child_count()):
		slots.append(grid.get_child(i))

	# Initialize inventory size and visuals
	inventory.resize(rows * columns)
	update_inventory_visuals()

	# Connect button signals
	for i in range(slots.size()):
		slots[i].connect("pressed", Callable(self, "_on_slot_pressed").bind(i))
func preload_item_icons():
	var sprite_folder = "res://UI/Inventory Interface/InventorySprites/"
	var dir = DirAccess.open(sprite_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.find(".png"):
				var icon_name = file_name.get_basename()
				item_icons[icon_name] = load(sprite_folder + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("cannot open")
			
func add_item(item: ItemData) -> bool:
	# Look for an existing stackable slot
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i].name == item.name:
			if inventory[i].amount < inventory[i].stack_limit:
				var remaining_space = inventory[i].stack_limit - inventory[i].amount
				var add_amount = min(item.amount, remaining_space)
				inventory[i].amount += add_amount
				item.amount -= add_amount
				if item.amount == 0:
					break  # All items added, no need to continue
				update_slot_visual(i)
			inventory_updated.emit()
			return true

	# Look for the first empty slot
	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = item.duplicate()  # Duplicate to prevent modifying original `.tres`
			inventory[i].amount = min(item.amount, item.stack_limit)
			item.amount -= inventory[i].amount
			update_slot_visual(i)
			inventory_updated.emit()
			if item.amount == 0:
				return true  # All items added
	print("Inventory is full!")
	return false

func remove_item(slot_index: int):
	if is_valid_slot(slot_index):
		inventory[slot_index] = null
		inventory_updated.emit()
		update_slot_visual(slot_index)
	else:
		print("Invalid slot index: %d" % slot_index)

func update_inventory_visuals():
	for i in range(inventory.size()):
		update_slot_visual(i)

func update_slot_visual(slot_index: int):
	if slot_index >= slots.size():
		return
	var button = slots[slot_index]
	if inventory[slot_index] != null:
		var item = inventory[slot_index]
		print("Proces:%s   (Path:%s)" % [item.name, item.asset_path])
		if item.name in item_icons:
			#var icon = load("res://UI/Inventory Interface/InventorySprites/pistol ammo.png")# Dynamically load the item icon
			# Set button icon and text
			button.icon = item_icons[item.name]
			
		else:
			button.icon = def_slot_icon
		#button.text = str(item.amount)  # Display the current quantity
	else:
		button.icon = def_slot_icon
		button.text = ""

func _on_slot_pressed(slot_index: int):
	if is_valid_slot(slot_index):
		var item = inventory[slot_index]
		print("Selected item: %s (Amount: %d)" % [item.name, item.amount])
	else:
		print("Empty slot.")

func set_focus_on_slot(slot_index: int):
	if slot_index >= 0 and slot_index < slots.size():
		var button = slots[slot_index]
		button.grab_focus()

func is_valid_slot(slot_index: int) -> bool:
	return slot_index >= 0 and slot_index < inventory.size() and inventory[slot_index] != null
