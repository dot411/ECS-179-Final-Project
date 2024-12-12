class_name Destructible
extends HP_Obj
##blocks path when active.
##calling activate will revive this object to full health if it's dead.

@onready var body = $Body

func init() -> void:
	super()
	data.team = 3

func get_body():
	return body

func activate():
	if data.HP == 0: data.HP = data.maxHP
	super()

func deactivate():
	if(self.name == "DestructableDoor"):
		self.queue_free();
	else:
		get_node("StaticBody2D/CollisionShape2D").set_deferred("disabled", true)
		super()

func death():
	if data.drop_items != null:
		var PickableItemScene = load("res://Main/Obj/PickableItem/pickable_item.tscn")
		for item_data in data.drop_items:
			var pickable_item = PickableItemScene.instantiate()
			pickable_item.item_data = item_data
			pickable_item.position = position + Vector2(randf_range(0.0, Utility.to_world_space(0.5)), 0).rotated(randf_range(0.0, TAU))
			Utility.get_GameScene().add_instance(pickable_item)
	deactivate()

func get_collision_radius():
	return Utility.to_world_space(1)
