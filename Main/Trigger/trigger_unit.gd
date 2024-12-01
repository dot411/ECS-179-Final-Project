@tool
class_name TriggerUnit
extends TriggerObject

enum unit_attributes {
	Attack,
	AbilityPower
}

func _init() -> void:
	super()
	_set("function", "triggering_caster")
