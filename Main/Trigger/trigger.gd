@tool
class_name Trigger
extends BaseData

var functions = {}
var selected_functions = {}
var buffer:TriggerBuffer
var helper_functions = HelperFunctions.new()

func init_categories(categories_name = ""):
	properties.category = 0
	var categories = [0]
	if categories_name != "":
		var name_parts = categories_name.split(".")
		categories = class_get_enum(name_parts[0], name_parts[1]).values()
		enum_properties.category = categories_name
	for value in categories:
		var category_key = str(value)
		functions[category_key] = {"queue": []}
		properties[category_key] = {}
		selected_functions[category_key] = ""

func get_categories_size():
	return selected_functions.size()

func add_function(category, data):
	var category_key = str(category)
	functions[category_key][data.name] = data
	functions[category_key].queue.append(data)
	properties[category_key][data.name] = {}

func add_functions(function_names, target, category):
	var list = target.get_method_list()
	for function_data in list:
		if !function_names.has(function_data.name): continue
		var data = function_data.duplicate(true)
		data.target = target
		if !functions[str(category)].has(data.name):
			add_function(category, data)
		for arg in data.args:
			var path = keys_to_path([category, data.name, arg.name])
			if is_property_enum_type(arg.class_name):
				enum_properties[path] = arg.class_name
			elif is_property_class_type(arg.class_name):
				class_properties[path] = arg.class_name

func copy_functions(from_category,to_category):
	var category_key = str(properties.category)
	for function_data in functions[category_key].queue:
		var data = function_data.duplicate(true)
		if !functions[str(to_category)].has(data.name):
			add_function(to_category, data)

func get_arr_as_hint_string(arr):
	var str_arr = []
	for item in arr:
		str_arr.append(item.name)
	return ",".join(str_arr)

func _get_property_list() -> Array[Dictionary]:
	var property_list:Array[Dictionary] = []
	var category_key = str(properties.category)
	var selected_function = selected_functions[category_key]
	if get_categories_size() > 1:
		add_property_to_list(property_list, 0, properties, "category")
	property_list.append({
		"name": "function",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": get_arr_as_hint_string(functions[category_key].queue),
		"usage": PROPERTY_USAGE_DEFAULT
	})
	if properties[category_key].has(selected_function):
		loop_properties(property_list, 0, properties[category_key][selected_function], keys_to_path([category_key, selected_function], false), false)
	return property_list

func _get(property: StringName) -> Variant:
	var category_key = str(properties.category)
	if property.begins_with("resource_"):
		return get_property(property)
	elif property == "category":
		return properties.category
	elif property == "function":
		return selected_functions[category_key]
	return get_property(str(category_key, "/", selected_functions[category_key], "/", property))

func _set(property: StringName, value: Variant) -> bool:
	if property.begins_with("resource_"):
		return set_property(property, value)
	elif property == "category":
		var prev_category_key = str(properties.category)
		var category_key = str(value)
		var selected_function = selected_functions[prev_category_key]
		if properties[category_key].has(selected_function):
			properties[category_key][selected_function] = properties[prev_category_key][selected_function]
			selected_functions[category_key] = selected_functions[prev_category_key]
		set_property(property, value)
		notify_property_list_changed()
		return true
	elif property == "function":
		var category_key = str(properties.category)
		selected_functions[category_key] = value
		var data = functions[category_key][value]
		clear_property(str(category_key, "/", value))
		for arg in data.args:
			set_property(str(category_key, "/", value, "/", arg.name), get_empty_value(arg.type))
		return true
	var category_key = str(properties.category)
	return set_property(str(category_key, "/", selected_functions[category_key], "/", property), value)

func get_function():
	var category_key = str(properties.category)
	return selected_functions[category_key]

func get_args():
	var category_key = str(properties.category)
	var selected_function = selected_functions[category_key]
	return properties[category_key][selected_function].values()

func run(trigger_buffer:TriggerBuffer):
	var category_key = str(properties.category)
	var selected_function = selected_functions[category_key]
	var args = properties[category_key][selected_function].values()
	buffer = trigger_buffer
	var result = callv(selected_function, args)
	buffer = null
	return result
