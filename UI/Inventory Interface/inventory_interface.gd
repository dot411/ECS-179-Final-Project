# InventoryInterface.gd
class_name InventoryInterface
extends Control

signal inventory_updated

@export var rows: int = 3
@export var columns: int = 3
var inventory: Array[ItemData] = []  # Start with an empty array

@onready var ui_node = get_parent()
@onready var grid = $NinePatchRect/GridContainer
@onready var slots = []
@onready var inv_background = $NinePatchRect

var def_slot_icon = preload("res://UI/temp_png/inventory-slot.png")
var item_icons: Dictionary = {}

func _ready():
	preload_item_icons()
	print("Initializing InventoryInterface...")
	for child in grid.get_children():
		if child is Button:
			child.custom_minimum_size = Vector2(25, 25)

	for i in range(grid.get_child_count()):
		slots.append(grid.get_child(i))
		slots[i].connect("pressed", Callable(self, "_on_slot_pressed").bind(i))

	# Just update visuals with empty inventory initially.
	update_inventory_visuals()

func preload_item_icons():
	var sprite_folder = "res://UI/Inventory Interface/InventorySprites/"
	var dir = DirAccess.open(sprite_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png"):
				var icon_name = file_name.get_basename()
				item_icons[icon_name] = load(sprite_folder + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("cannot open sprite folder:", sprite_folder)

#func add_item(item: ItemData) -> bool:
	## First try to stack with an identical existing item if stackable
	#for i in range(inventory.size()):
		#var existing_item = inventory[i]
		#if existing_item.name == item.name and existing_item.amount < existing_item.stack_limit:
			#var remaining_space = existing_item.stack_limit - existing_item.amount
			#var to_add = min(item.amount, remaining_space)
			#existing_item.amount += to_add
			#item.amount -= to_add
			#update_slot_visual(i)
			#inventory_updated.emit()
			#if item.amount <= 0:
				## All added
				#return true
	## If there's still some left, add as a new entry if possible

	#inventory.append(item.duplicate(true))
	#update_inventory_visuals()
	#inventory_updated.emit()
	#return true
func add_item(item: ItemData) -> bool:
	print("add_item called with:", item.name, "Amount:", item.amount)
	inventory.append(item.duplicate(true))
	print("Inventory size after adding:", inventory.size())
	update_inventory_visuals()
	inventory_updated.emit()
	return true


func remove_item(item: ItemData):
	var slot_index = find_item_index_by_name(item.name)
	if slot_index != -1:
		inventory.remove_at(slot_index)
		update_inventory_visuals()
		inventory_updated.emit()
		print("Removed item: %s from Slot ID: %d" % [item.name, slot_index])
		return
	print("Item not found in inventory: %s" % item.name)

func update_item_quantity(item: ItemData, to_amount: int):
	var slot_index = find_item_index_by_name(item.name)
	if slot_index != -1:
		if to_amount <= 0:
			# Removing the item entirely
			inventory.remove_at(slot_index)
			update_inventory_visuals()
			inventory_updated.emit()
			print("Removed item: %s" % item.name)
		else:
			inventory[slot_index].amount = min(to_amount, item.stack_limit)
			update_slot_visual(slot_index)
			inventory_updated.emit()
			print("Updated item: %s to amount: %d" % [item.name, inventory[slot_index].amount])
		return
	print("Item not found in inventory: %s" % item.name)

func update_inventory_visuals():
	
	print("update_inventory_visuals called. Inventory size:", inventory.size())
	for i in range(rows * columns):
		update_slot_visual(i)

func update_slot_visual(slot_index: int):
	if slot_index >= slots.size():
		return
	var button = slots[slot_index]
	var label:Label = null
	for child in button.get_children():
		if child is Label:
			label = child
			break

	if slot_index < inventory.size():
		var slot_item = inventory[slot_index]
		if slot_item.name in item_icons:
			button.icon = item_icons[slot_item.name]
		else:
			button.icon = def_slot_icon
		label.text = str(slot_item.amount)
		label.visible = true
	else:
		# This slot is empty
		button.icon = def_slot_icon
		label.text = ""
		label.visible = true

func _on_slot_pressed(slot_index: int):
	if slot_index < inventory.size():
		var item = inventory[slot_index]
		ui_node.item_selected_from_action_bar(item)
		print("Selected item: %s (Amount: %d)" % [item.name, item.amount])
	else:
		print("Empty slot.")

func set_focus_on_slot(slot_index: int):
	if slot_index >= 0 and slot_index < slots.size():
		var button = slots[slot_index]
		button.grab_focus()

func find_item_index_by_name(item_name: String) -> int:
	for i in range(inventory.size()):
		var existing_item = inventory[i]
		if existing_item.name == item_name:
			return i
	return -1

func debug_inventory_slots():
	print("=== Debugging Inventory Slots ===")
	for i in range(inventory.size()):
		var slot_item = inventory[i]
		print("Slot Index: %d | Item: %s | Amount: %d" % [i, slot_item.name, slot_item.amount])
	print("=== End of Inventory Debug ===")
