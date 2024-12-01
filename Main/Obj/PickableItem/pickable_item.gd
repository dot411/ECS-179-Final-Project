class_name PickableItem
extends Obj

var item_data:ItemData

func _ready() -> void:
	if item_data == null: return
	await get_tree().create_timer(0.5).timeout
	get_node("Area2D").body_entered.connect(_on_area_2d_body_entered)

func _on_area_2d_body_entered(body: Node2D) -> void:
	var target = body.get_parent()
	if body is not CharacterBody2D or target.controller is not Player: return
	target.gain_item(item_data)
	queue_free()
