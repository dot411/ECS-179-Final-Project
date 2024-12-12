class_name Projectile
extends Node2D

@onready var effect_region = $EffectRegion
var data:ProjectileData
var active = true

func _ready() -> void:
	effect_region.collision_mask = 0b11
	effect_region.monitorable = true
	if data.asset_file_path != null:
		get_node("Sprite").texture = load(data.asset_file_path)

func _physics_process(delta: float) -> void:
	if !active: return
	var _velocity = Utility.to_world_space(data.speed)
	var dir = Vector2.from_angle(rotation).normalized()
	position += dir * _velocity * delta

func _on_effect_region_body_entered(new_target_body: Node2D) -> void:
	if new_target_body is TileMapLayer:
		queue_free()

func _on_effect_region_tree_exited() -> void:
	queue_free()

func _on_effect_region_removed() -> void:
	active = false
