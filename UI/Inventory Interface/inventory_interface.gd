class_name InventoryInterface
extends Control

# Signal to notify the UI about inventory updates
signal inventory_updated

# Inventory item slots using an Array
@export var inventory: Array[ItemData] = []

# Rows and columns for the grid layout
@export var rows: int = 2
@export var columns: int = 5

#  or referencing the grid 
@onready var grid = $GridContainer

#start with a specified amount of slots
func _ready():
	inventory.resize(rows * columns)  # Match inventory size to grid
	create_inventory_grid()

# Add an item to the inventory
func add_item(item: ItemData) -> bool:
	# Check for the first empty slot
	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = item
			inventory_updated.emit()  # Notify the UI
			update_slot_visual(i)  # Update the slot's visual
			return true
	# If no empty slot is found
	print("Inventory is full!")
	return false

# Remove an item from the inventory by slot index
func remove_item(slot_index: int):
	if is_valid_slot(slot_index):
		inventory[slot_index] = null
		inventory_updated.emit()  # Notify the UI
		update_slot_visual(slot_index)  # Update the slot's visual
	else:
		print("Invalid slot index: %d" % slot_index)

# Update the quantity of an existing item
func update_item_quantity(item: ItemData, new_quantity: int):
	for i in range(inventory.size()):
		if inventory[i] == item:
			if new_quantity <= 0:
				remove_item(i)  # Remove the item if the quantity is zero or less
			else:
				item.quantity = new_quantity
				inventory_updated.emit()  # Notify the UI
				update_slot_visual(i)  # Update the slot's visual
			return
	print("Item not found in inventory.")

# Create buttons dynamically for the inventory grid
func create_inventory_grid():
	#grid.clear_children()  # Remove old buttons
	for i in range(inventory.size()):
		var button = Button.new()
		button.text = "Slot %d" % i  # Default text for the button
		button.connect("pressed", Callable(self, "_on_slot_pressed").bind(i))  # Connect button press
		grid.add_child(button)


# Update a specific slot's visual representation
func update_slot_visual(slot_index: int):
	if slot_index >= grid.get_child_count():
		return  # Out of bounds, ignore
	var button = grid.get_child(slot_index) as Button
	if inventory[slot_index] != null:
		button.text = inventory[slot_index].name  # Set item name
	else:
		button.text = "Empty"  # Set empty text for unused slots

# Handle slot selection
func _on_slot_pressed(slot_index: int):
	if is_valid_slot(slot_index):
		print("Selected item: %s" % inventory[slot_index].name)
	else:
		print("Empty slot.")
		

# Get the current state of the inventory
func get_inventory() -> Array:
	return inventory

# Check if a slot index is valid
func is_valid_slot(slot_index: int) -> bool:
	return slot_index >= 0 and slot_index < inventory.size() and inventory[slot_index] != null
	
func highlight_slot(slot_index: int):
	for i in range(grid.get_child_count()):
		var button = grid.get_child(i) as Button
		button.modulate = Color(1,1,1,1)
	
	if slot_index >= 0 and slot_index < grid.get_child_count():
		var selected_button = grid.get_child(slot_index) as Button
		selected_button.modulate = Color(1,0,0,1)
