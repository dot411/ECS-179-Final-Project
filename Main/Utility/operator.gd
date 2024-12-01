@tool
class_name Operator
extends EnumEditable

func _init() -> void:
	members.append("+")
	members.append("-")
	members.append("*")
	members.append("/")

func compute(value1, value2):
	var operator = members[selected]
	if operator == "+": return value1 + value2
	elif operator == "-": return value1 - value2
	elif operator == "*": return value1 * value2
	elif operator == "/": return value1 / value2
	return null
