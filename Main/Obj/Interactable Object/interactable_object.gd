class_name InteractableObject
extends Obj
##switch active status when interacted
@export var matches:Fireplace

func interact(unit):
	if data.active:
		if data.allow_deactivation:
			deactivate()
	else:
		if data.requires_resource != "" and data.requires_resource_amount != 0 and !unit.spend_item_based_on_name(data.requires_resource, data.requires_resource_amount):
			return
		for item in data.give_inventory:
			unit.gain_item(item)
		activate()
