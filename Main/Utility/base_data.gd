class_name BaseData
extends Resource

var properties = {}
var enum_properties = {}
var class_properties = {}
var ranged_properties = {}

func loop_properties(property_list, depth, dict, path = "", include_path_in_name = true):
	for key in dict.keys():
		add_property_to_list(property_list, depth, dict, key, path, include_path_in_name)

func add_property_to_list(property_list, depth, dict, key, path = "", include_path_in_name = true):
	var value = dict[key]
	var property_type = typeof(value)
	var data = {
		"name": key,
		"type": property_type,
		"usage": PROPERTY_USAGE_DEFAULT
	}
	var full_path = str(path, key)
	if include_path_in_name: data.name = full_path
	if enum_properties.keys().has(full_path):
		var name_parts = enum_properties[full_path].split(".")
		var enum_values = class_get_enum_constants(name_parts[0], name_parts[1])
		data.hint = PROPERTY_HINT_ENUM
		data.hint_string = ",".join(enum_values)
	elif class_properties.keys().has(full_path):
		data.type = TYPE_OBJECT
		data.hint = PROPERTY_HINT_RESOURCE_TYPE
		data.hint_string = class_properties[full_path]
	if property_type == TYPE_DICTIONARY:
		loop_properties(property_list, depth + 1, value, str(path, key, "/"))
		return
	if ranged_properties.keys().has(full_path):
		var values = ranged_properties[full_path]
		data.hint = PROPERTY_HINT_RANGE
		data.hint_string = str(values[0], ",", values[1], ",", values[2])
	property_list.append(data)

func find_class(_class_name):
	var class_list = ProjectSettings.get_global_class_list()
	for class_data in class_list:
		if class_data.class == _class_name:
			return load(class_data.path)
	return null

func class_has_enum(_class_name, _enum_name):
	var script = find_class(_class_name)
	if script == null: return false
	if script.get(_enum_name): return true
	return false

func class_get_enum(_class_name, _enum_name):
	var script = find_class(_class_name)
	if script == null: return null
	return script.get(_enum_name)

func class_get_enum_constants(_class_name, _enum_name):
	var _enum = class_get_enum(_class_name, _enum_name)
	if _enum == null: return []
	return _enum.keys()

func is_property_enum_type(_name):
	if _name.find(".") == -1: return false
	var name_parts = _name.split(".")
	if class_has_enum(name_parts[0], name_parts[1]): return true
	return false

func is_property_class_type(_name):
	if _name == "": return false
	return find_class(_name) != null

func get_empty_value(type_value):
	if type_value == TYPE_INT: return 0
	if type_value == TYPE_FLOAT: return 0.0
	if type_value == TYPE_STRING: return ""
	if type_value == TYPE_VECTOR2: return Vector2(0, 0)
	if type_value == TYPE_BOOL: return false
	if type_value == TYPE_COLOR: return Color(0, 0, 0)
	return null

func keys_to_path(keys, is_final = true):
	var path = "/".join(keys)
	if !is_final: path = str(path, "/")
	return path

func get_property_loop(dict, keys):
	if keys.size() == 0: return null
	var key = keys[0]
	if keys.size() == 1 and dict.has(key): return dict[key]
	if !dict.has(key) or dict[key] is not Dictionary: return null
	keys.remove_at(0)
	return get_property_loop(dict[key], keys)

func get_property(property):
	if property.begins_with("resource_"):
		if property == "resource_local_to_scene": return resource_local_to_scene
		elif property == "resource_path": return resource_path
		elif property == "resource_name": return resource_name
	var keys = [property]
	if property.find("/") != -1: keys = property.split("/")
	return get_property_loop(properties, keys)

func set_property_loop(dict, keys, value):
	if keys.size() == 0: return false
	var key = keys[0]
	if keys.size() == 1:
		var notify_change = !dict.has(key)
		dict[key] = value
		if notify_change: notify_property_list_changed()
		else: emit_changed()
		return true
	if !dict.has(key) or dict[key] is not Dictionary: return false
	keys.remove_at(0)
	return set_property_loop(dict[key], keys, value)

func set_property(property, value):
	if property == "RESET":
		_init()
		return
	if property.begins_with("resource_"):
		if property == "resource_local_to_scene": resource_local_to_scene = value
		elif property == "resource_path": resource_path = value
		elif property == "resource_name": resource_name = value
		return true
	var keys = [property]
	if property.find("/") != -1: keys = property.split("/")
	var result_status = set_property_loop(properties, keys, value)
	return result_status

func clear_property_loop(dict, keys):
	if keys.size() == 0: return false
	var key = keys[0]
	if keys.size() == 1 and dict.has(key):
		var value = dict[key]
		if value is Dictionary:
			value.clear()
			notify_property_list_changed()
			return true
		return false
	if !dict.has(key) or dict[key] is not Dictionary: return false
	keys.remove_at(0)
	clear_property_loop(dict[key], keys)

func clear_property(property):
	var keys = [property]
	if property.find("/") != -1: keys = property.split("/")
	clear_property_loop(properties, keys)

func erase_property_loop(dict, keys):
	if keys.size() == 0: return false
	var key = keys[0]
	if keys.size() == 1 and dict.has(key):
		dict.erase(key)
		notify_property_list_changed()
		return true
	if !dict.has(key) or dict[key] is not Dictionary: return false
	keys.remove_at(0)
	return erase_property_loop(dict[key], keys)

func erase_property(property):
	var keys = [property]
	if property.find("/") != -1: keys = property.split("/")
	erase_property_loop(properties, keys)
