@tool
class_name PositionEffect
extends Effect

@export_range(0.0, 10.0, 0.01) var distance_modifier:float
@export_range(-180.0, 180.0, 0.01) var angle_modifier:float

func _init() -> void:
	init_categories()
	add_functions(["spawn_effect_region", "spawn_projectile", "spawn_unit"], AbilityController.new(), 0)
