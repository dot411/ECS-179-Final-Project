class_name UI
extends Node

#Receiver Functions

#append a game message (dialogue) that lasts _time seconds to the queue
#game messages should be displayed from the queue one by one until the queue becomes empty
func append_game_message_request(_text:String, _time:float):
	pass

#update the interface to reflect the change
#erase the item from player_inventory if to_amount == 0
func player_item_amount_changed(player_inventory:Array[ItemData], item:ItemData, to_amount:int):
	pass

#assign and update item.slot_id to keep track of their position in the inventory interface
func player_gains_new_item(player_inventory:Array[ItemData], item:ItemData):
	pass

#update visual for HP
func player_HP_update_request(current_HP:int, max_HP:int):
	pass

#fatigued means that the player is in a cooldown period waiting for fatigue to drop to zero
func player_fatigue_update_request(current_fatigue:float, max_fatigue:float, fatigued:bool):
	pass

func player_attack_attribute_update_request(attack:int):
	pass

func player_ability_power_attribute_update_request(ability_power:int):
	pass

func obj_healed(_node:Obj, amount:int):
	#_node.add_child(heal_indicator)
	pass

func obj_damaged(_node:Obj, amount:int):
	#_node.add_child(damage_indicator)
	pass


#Emitter Functions

#emit if a new item is selected from the action bar
func item_selected_from_action_bar(item:ItemData):
	get_player_node().select_item(item)


#Helper Functions
func get_player_node():
	return Utility.get_player_node()
