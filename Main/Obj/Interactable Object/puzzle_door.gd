class_name PuzzleDoor
extends InteractableObject

@export var my_door: Destructible 
@export var required_resource: String  
@export var required_amount: int = 1

func door_interact(unit):
	#if my_door and my_door.data.HP > 0:  
	if required_resource != "" and required_amount != 0:
		if unit.spend_item_based_on_name(required_resource, required_amount):
			my_door.deactivate() 
			print("You opened the door!")
		else:
			print("You need a key.")
	else:
		print("This object requires a resource to activate.")
	#else:
		#print("The door is already unlocked.")
