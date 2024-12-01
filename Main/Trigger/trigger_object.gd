@tool
class_name TriggerObject
extends Trigger

func _init() -> void:
	init_categories()
	add_functions(["triggering_event_object", "triggering_caster", "triggering_affected"], self, 0)
	_set("function", "triggering_event_object")

func triggering_event_object():
	return buffer.triggering_event_object

func triggering_caster():
	return buffer.triggering_caster

func triggering_affected():
	return buffer.triggering_affected
