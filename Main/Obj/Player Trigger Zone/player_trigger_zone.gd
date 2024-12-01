class_name PlayerTriggerZone
extends Obj

func _on_area_2d_body_entered(body: Node2D) -> void:
	var target = body.get_parent()
	if body is not CharacterBody2D or target.controller is not Player: return
	activate()

func _on_area_2d_body_exited(body: Node2D) -> void:
	var target = body.get_parent()
	if body is not CharacterBody2D or target.controller is not Player: return
	deactivate()
