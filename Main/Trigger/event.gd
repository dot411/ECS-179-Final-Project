@tool
class_name Event
extends Trigger

func _init() -> void:
	init_categories()
	add_functions(["object_activated", "object_deactivated"], self, 0)
	_set("function", "object_activated")

func object_activated():
	return true

func object_deactivated():
	return true

func run(trigger_buffer:TriggerBuffer):
	if _get("function") == trigger_buffer.triggering_event: return super(trigger_buffer)
	return false
