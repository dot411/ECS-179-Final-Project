extends PlayerTriggerZone

@export var path:SceneFilePath = SceneFilePath.new()
@export var pos:Vector2 = Vector2(0, 0)

func _ready():
	data = ObjData.new()
	data.triggers.append(TriggerEditable.new())
	var _trigger = data.triggers[0]
	_trigger.one_shot = false
	_trigger.event = Event.new()
	_trigger.event._set("function", "object_activated")
	var action = Action.new()
	action._set("function", "go_to_map")
	action._set("path", path)
	action._set("pos", pos)
	_trigger.actions.append(action)
