@tool
class_name DebugSettingData
extends BaseData

func _init() -> void:
	properties = {
		"reset": false,
		"debug_mode_on": false,
		"general": {
			"status": false,
			"show_effect_region": false
		},
		"unit": {
			"status": false,
			"show_collision": false
		},
		"player": {
			"status": false,
			"show_interact_range": false
		},
		"game_AI": {
			"status": false,
			"show_aggro_range": false,
			"show_raycast": false,
			"show_targeting": false
		}
	}

func _get_property_list() -> Array[Dictionary]:
	var property_list:Array[Dictionary] = []
	if !_get("debug_mode_on"):
		add_property_to_list(property_list, 0, properties, "reset")
		add_property_to_list(property_list, 0, properties, "debug_mode_on")
	else:
		loop_properties(property_list, 0, properties)
	return property_list

func _get(property: StringName) -> Variant:
	return get_property(property)

func _set(property: StringName, value: Variant) -> bool:
	if property == "reset":
		properties.clear()
		_init()
		_set("debug_mode_on", value)
	elif property == "debug_mode_on":
		notify_property_list_changed()
	elif property == "general/status":
		set_property("general/show_effect_region", value)
	elif property == "unit/status":
		set_property("unit/show_collision", value)
	elif property == "player/status":
		set_property("player/show_interact_range", value)
	elif property == "game_AI/status":
		set_property("game_AI/show_aggro_range", value)
		set_property("game_AI/show_raycast", value)
		set_property("game_AI/show_targeting", value)
	return set_property(property, value)
