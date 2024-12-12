@tool
class_name EffectRegionData
extends BaseData

@export_file var asset_file_path
@export var area_shape:AreaShape
@export var effect:AreaEffect
@export var follow_parent = true

func _init() -> void:
	properties = {
		"wait_for_collision_to_trigger": false,
		"one_shot": true,
		"targets_limit": false,
		"max_affected": 1,
		"periodic": false,
		"finite_duration": false,
		"lifetime": 1.0,
		"cooldown": 0.5,
	}
	ranged_properties.max_affected = [0, 10, 1]
	ranged_properties.lifetime = [0.0, 60.0, 0.01]
	ranged_properties.cooldown = [0.0, 10.0, 0.01]

func _get_property_list() -> Array[Dictionary]:
	var property_list:Array[Dictionary] = []
	add_property_to_list(property_list, 0, properties, "targets_limit")
	if _get("targets_limit"): add_property_to_list(property_list, 0, properties, "max_affected")
	add_property_to_list(property_list, 0, properties, "wait_for_collision_to_trigger")
	if _get("wait_for_collision_to_trigger"):
		add_property_to_list(property_list, 0, properties, "one_shot")
		add_property_to_list(property_list, 0, properties, "finite_duration")
		if _get("finite_duration"): add_property_to_list(property_list, 0, properties, "lifetime")
	else:
		add_property_to_list(property_list, 0, properties, "periodic")
		if _get("periodic"):
			add_property_to_list(property_list, 0, properties, "finite_duration")
			if _get("finite_duration"): add_property_to_list(property_list, 0, properties, "lifetime")
			add_property_to_list(property_list, 0, properties, "cooldown")
	return property_list

func _get(property: StringName) -> Variant:
	return get_property(property)

func _set(property: StringName, value: Variant) -> bool:
	var result_status = set_property(property, value)
	notify_property_list_changed()
	return result_status
