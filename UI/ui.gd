class_name UI
extends Control

@onready var game_message_manager = $GameMessage
@onready var main_menu = $MainMenu
@onready var in_game_control = $in_game_control
@onready var pause_screen = $PauseScreen
var is_inventory_visible:bool = false
var selected_slot = -1

func hide_ingame_control():
	$InventoryInterface.visible = false
	$ValueIndicator.visible = false
	$GameMessage.visible = false
	$PauseMenu.visible = false
	$MainMenu.visible = true

func _ready():
	hide_ingame_control()
	var inventory_interface = get_node_or_null("InventoryInterface")  
	if inventory_interface:
		inventory_interface.connect("inventory_updated", Callable(self,"updated_inventory_visuals"))
		inventory_interface.visible = false
	else:
		print("Error: InventoryInterface node not found.")
func  start_game_ui():
	main_menu.visible = false
	$ValueIndicator.visible = true
	$GameMessage.visible = true
	game_message_manager.add_message("Welcome To Resident Medieval",5.0)
	game_message_manager.add_message("Here is how to play", 3.0)
	game_message_manager.add_message("Use 'WASD' to move , 'i' for inventory, 'inventory Keybinds are #'s 1-9", 8.0)
	game_message_manager.add_message("Select the weapon/item using the #1-9", 8.0)
	game_message_manager.add_message("Press 'e' to interact and left mouse click to fire", 8.0)
	await get_tree().create_timer(40).timeout
	game_message_manager.clear_messages()
	print("switched")
func resume_game():
	$PauseMenu.visible = false
	$ValueIndicator.visible = true
	$GameMessage.visible = true
	
	
func append_game_message_request(_text: String, _time: float):
	var game_message_manager = get_node_or_null("GameMessage")
	if game_message_manager:
		game_message_manager.add_message(_text, _time)
	else:
		print("error")

func player_item_amount_changed(player_inventory: Array[ItemData], item: ItemData, to_amount: int):
	var inventory_interface = get_node_or_null("InventoryInterface")
	if inventory_interface:
		#print("player_item_amount_changed called for %s (to_amount: %d)" % [item.name, to_amount])
		inventory_interface.update_item_quantity(item, to_amount)
	else:
		print("Error: InventoryInterface node not found.")
	pass

func player_gains_new_item(player_inventory: Array[ItemData], item: ItemData):
	print("player_gains_new_item called with item:", item.name, "Amount:", item.amount)
	var inventory_interface = get_node_or_null("InventoryInterface")
	if inventory_interface:
		#print("Adding new item to inventory: %s (Amount: %d)" % [item.name, item.amount])
		if not inventory_interface.add_item(item):
			print("Inventory Full")
		inventory_interface.debug_inventory_slots()			# Do NOT modify the currently selected item here
	else:
		print("Error: InventoryInterface node not found.")

func updated_inventory_visuals():
	var inventory_interface = get_node_or_null("InventoryInterface")
	if inventory_interface:
		inventory_interface.update_inventory_visuals()


func _input(event):
	if event.is_action_pressed("Pause"):
		$InventoryInterface.visible = false
		$ValueIndicator.visible = false
		$GameMessage.visible = false
		$PauseMenu.visible = true
	if event.is_action_pressed("ui_toggle_inventory"):
		is_inventory_visible = !is_inventory_visible
		var inventory_interface = get_node_or_null("InventoryInterface")  
		if inventory_interface:
			inventory_interface.visible = is_inventory_visible
	
	if is_inventory_visible:
		for i in range(1,11):
			if event.is_action_pressed("select_slot_%d"%i):
				selected_slot = i - 1
				print("Selected Slot: %d" % selected_slot)
				
				var inventory_interface = get_node_or_null("InventoryInterface")
				if inventory_interface:
					inventory_interface.set_focus_on_slot(selected_slot)
					inventory_interface._on_slot_pressed(selected_slot)
					#
					var item = inventory_interface.inventory[selected_slot]
					get_player_node().select_item(item)

func player_HP_update_request(current_HP: int, max_HP: int):
	var value_indicator = get_node_or_null("ValueIndicator")
	if value_indicator:
		value_indicator.update_health(current_HP, max_HP)

func player_fatigue_update_request(current_fatigue: float, max_fatigue: float, fatigued: bool):
	var value_indicator = get_node_or_null("ValueIndicator")
	if value_indicator:
		value_indicator.update_fatigue(current_fatigue, max_fatigue, fatigued)

func player_attack_attribute_update_request(attack: int):
	pass

func player_ability_power_attribute_update_request(ability_power: int):
	pass

func obj_healed(_node: Obj, amount: int):
	pass

func obj_damaged(_node: Obj, amount: int):
	pass

func item_selected_from_action_bar(item: ItemData):
	#if item:
		#print("Action Bar Item Selected: %s (Amount: %d)" % [item.name, item.amount])
	#else:
		#print("Action Bar Item Selected: NONE")
	get_player_node().select_item(item)

func get_player_node():
	return Utility.get_player_node()
