class_name Projectile
extends Node2D

@onready var effect_region = $EffectRegion
var data:ProjectileData

func _ready() -> void:
	effect_region.collision_mask = 0b11
	effect_region.monitorable = true

func _physics_process(delta: float) -> void:
	var _velocity = Utility.to_world_space(data.speed)
	var dir = Vector2.from_angle(rotation).normalized()
	position += dir * _velocity * delta

func _on_effect_region_body_entered(new_target_body: Node2D) -> void:
	if new_target_body is TileMapLayer:
		queue_free()

func _on_effect_region_tree_exited() -> void:
	queue_free()
