@tool
class_name Action
extends Trigger

@export var target:NodePath

func _init(value:int = 0) -> void:
	init_categories()
	add_functions(["activate_target", "deactivate_target", "send_game_message", "go_to_map"], self, 0)

func activate_target():
	var target_node = buffer.triggering_event_object.get_node(target)
	target_node.activate()

func deactivate_target():
	var target_node = buffer.triggering_event_object.get_node(target)
	target_node.deactivate()

func send_game_message(_text:String, _time:FloatPoint):
	buffer.UI_node.append_game_message_request(_text, _time.run(buffer))

func go_to_map(path:SceneFilePath, pos:Vector2):
	buffer.game_scene_node.go_to_map(path, pos)
