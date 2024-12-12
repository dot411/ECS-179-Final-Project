class_name AbilityObject
extends Obj

var ability_data:AbilityData = AbilityData.new()
var ability_controller:AbilityController = AbilityController.new()
var spawned_units = []
var home_pos:Vector2
var temporary_active_flag = true

func init() -> void:
	if ability_data == null:
		queue_free()
		return
	super()
	data.team = 2
	get_node("Area2D/CollisionShape2D").modulate.a = 0
	if data.disable_when_player_is_nearby:
		get_node("Area2D/CollisionShape2D").shape.radius = Utility.to_world_space(5)
		get_node("Area2D").body_entered.connect(_on_area_2d_body_entered)
		get_node("Area2D").body_exited.connect(_on_area_2d_body_exited)
	home_pos = position
	ability_data.cooldown = data.cooldown
	ability_data.cooldown_time_left = data.start_delay
	ability_data.channeling_track = [ChannelingInterval.new()]
	ability_data.channeling_track[0].position_effects = data.position_effects.duplicate(true)
	ability_controller.caster = self
	add_child(ability_controller)
	ability_controller.bind_ability(ability_data)
	ability_controller.cooldown_timer.timeout.connect(cast)
	if data.start_delay == 0: cast()

func new_pos():
	var pos = Vector2(randf_range(0.0, Utility.to_world_space(data.max_aim_distance)), 0)
	var angle = randf_range(0.0, deg_to_rad(data.max_aim_angle))
	return home_pos + pos.rotated(angle)

func cast():
	if !data.active or !temporary_active_flag: return
	if data.unit_spawn_limit != -1 and spawned_units.size() >= data.unit_spawn_limit: return
	var space_state = get_world_2d().direct_space_state
	var pos
	for i in range(100):
		pos = new_pos()
		if vision_intersect_ray(space_state, position, pos).size() == 0:
			position = pos
			break
	update_facing_angle(randf_range(0.0, deg_to_rad(data.max_aim_angle)))
	ability_controller.track_caster_aim(position)
	ability_controller.use()

func _on_spawned_unit_exited():
	for i in range(spawned_units.size() - 1, -1, -1):
		if spawned_units[i] == null: spawned_units.remove_at(i)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !data.disable_when_player_is_nearby: return
	var target = body.get_parent()
	if body is not CharacterBody2D or target.controller is not Player: return
	temporary_active_flag = false

func _on_area_2d_body_exited(body: Node2D) -> void:
	if !data.disable_when_player_is_nearby: return
	var target = body.get_parent()
	if body is not CharacterBody2D or target.controller is not Player: return
	temporary_active_flag = true
