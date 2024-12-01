class_name Obj
extends Node2D
##Base entity class

##emit when an object becomes active or inactive
signal active_state_changed(state:bool)
##radian angle from -pi to pi
signal facing_angle_changed(angle:float)

##initial value for active or inative
@export var start_status = false
@export_dir var asset_path
@export var data:ObjData
var trigger_buffer:TriggerBuffer = TriggerBuffer.new()
var facing_angle:float

func init() -> void:
	if data.active == null: data.active = start_status

func fire_trigger_event(event_name):
	trigger_buffer.game_scene_node = Utility.get_GameScene()
	trigger_buffer.UI_node = Utility.get_UI_Scene()
	for _trigger in data.triggers:
		if _trigger.event == null: continue
		trigger_buffer.triggering_event = event_name
		_trigger.run(trigger_buffer)
		trigger_buffer.triggering_event = ""

func activate():
	data.active = true
	fire_trigger_event("object_activated")
	emit_signal("active_state_changed", data.active)

func deactivate():
	data.active = false
	fire_trigger_event("object_deactivated")
	emit_signal("active_state_changed", data.active)

func get_body():
	return self

func get_pos():
	return position

func get_collision_radius():
	return 0.0

func vision_intersect_ray(space_state, from, to):
	var ray_query = PhysicsRayQueryParameters2D.create(from, to, 0b1)
	return space_state.intersect_ray(ray_query)

func apply_effect(effect:Effect):
	if has_method(effect.get_function()):
		callv(effect.get_function(), effect.get_args())

func get_facing_angle():
	return facing_angle

func update_facing_angle(angle):
	facing_angle = angle

func death():
	queue_free()
