class_name EnumEditable
extends Resource

var members = []
var selected:int = 0

func _get_property_list() -> Array[Dictionary]:
	var property_list:Array[Dictionary] = []
	property_list.append({
		"name": "selected",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(members),
		"usage": PROPERTY_USAGE_DEFAULT
	})
	return property_list
