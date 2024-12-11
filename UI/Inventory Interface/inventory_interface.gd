class_name InventoryInterface
extends Control

signal inventory_updated

@export var inventory: Array[ItemData] = []
@export var rows: int = 3
@export var columns: int = 3

@onready var ui_node = get_parent()
@onready var grid = $NinePatchRect/GridContainer 
@onready var slots = []  #for buttons
@onready var inv_backround =  $NinePatchRect
var def_slot_icon = preload("res://UI/temp_png/inventory-slot.png")

func _ready():
	print('UI Node:',ui_node)
	# fill slots with buttons
	for child in grid.get_children():
		if child is Button:
			child.custom_minimum_size = Vector2(25,25)
	for i in range(grid.get_child_count()):
		slots.append(grid.get_child(i))

	# Initialize inventory size
	inventory.resize(rows * columns)
	update_inventory_visuals()

	# Connect button signals
	for i in range(slots.size()):
		slots[i].connect("pressed", Callable(self, "_on_slot_pressed").bind(i))

func add_item(item: ItemData) -> bool:
	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = item
			inventory_updated.emit()
			update_slot_visual(i)
			return true
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
		button.icon = preload("res://icon.svg")
	else:
		button.icon = preload("res://UI/temp_png/UniqueBorderV11.png") #def_slot_icon

func _on_slot_pressed(slot_index: int):
	if is_valid_slot(slot_index):
		if ui_node:
			ui_node.item_selected_from_action_bar(inventory[slot_index])
		else:
			print("null")
		print("Selected item: %s" % inventory[slot_index].name)
	else:
		print("Empty slot.")
		
func set_focus_on_slot(slot_index:int):
	if slot_index >= 0 and slot_index < slots.size():
		var button = slots[slot_index]
		button.grab_focus()
func is_valid_slot(slot_index: int) -> bool:
	return slot_index >= 0 and slot_index < inventory.size() and inventory[slot_index] != null
