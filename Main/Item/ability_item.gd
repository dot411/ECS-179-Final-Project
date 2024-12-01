@tool
class_name AbilityItem
extends ItemData

@export var ability_data:AbilityData

func _init() -> void:
	properties = {
		"consumable": false,
		"cost_resource": false,
		"resource_name": "",
		"cost_amount": 1
	}

func _get_property_list() -> Array[Dictionary]:
	var property_list:Array[Dictionary] = []
	add_property_to_list(property_list, 0, properties, "consumable")
	if !_get("consumable"):
		add_property_to_list(property_list, 0, properties, "cost_resource")
		if _get("cost_resource"):
			add_property_to_list(property_list, 0, properties, "resource_name")
			add_property_to_list(property_list, 0, properties, "cost_amount")
	return property_list

func _get(property: StringName) -> Variant:
	return get_property(property)

func _set(property: StringName, value: Variant) -> bool:
	var result_status = set_property(property, value)
	if value is bool:
		notify_property_list_changed()
	return result_status
