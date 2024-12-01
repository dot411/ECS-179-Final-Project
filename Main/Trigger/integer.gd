@tool
class_name Integer
extends Trigger

func _init(value:int = 0) -> void:
	init_categories()
	add_functions(["raw_value", "arithmetic", "unit_attribute"], self, 0)
	_set("function", "raw_value")
	_set("value", value)

func raw_value(value:int):
	return value

func arithmetic(value1:Integer, operator:Operator, value2:Integer):
	return operator.compute(value1.run(buffer), value2.run(buffer))

func unit_attribute(unit:TriggerUnit, attribute:TriggerUnit.unit_attributes, modifier:float, multiplier:float):
	return int(float(helper_functions.unit_attribute(buffer, unit, attribute)) * multiplier + modifier)
