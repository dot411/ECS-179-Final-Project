class_name TriggerEditable
extends Resource

@export var one_shot = true
@export var event:Event
@export var actions:Array[Action]
var active = true

func run(trigger_buffer:TriggerBuffer):
	if !active: return
	if !event.run(trigger_buffer): return
	for action in actions:
		action.run(trigger_buffer)
	if one_shot: active = false
