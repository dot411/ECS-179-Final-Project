class_name EffectRegion
extends Area2D

signal removed
var trigger_buffer:TriggerBuffer = TriggerBuffer.new()
var debug_on = false
var affected = []
var bodies_to_skip = []
var life_timer = Timer.new()
var cooldown_timer = Timer.new()
var active = true
var area_shape:AreaShape
var effect:AreaEffect
var data:EffectRegionData

func _ready() -> void:
	if data == null:
		remove()
		return
	area_shape = data.area_shape
	effect = data.effect
	if area_shape == null or effect == null:
		remove()
		return
	init_debug_mode()
	init_area_shape()
	if data._get("wait_for_collision_to_trigger"):
		body_entered.connect(_on_effect_region_body_entered)
		if data._get("finite_duration"):
			init_life_timer()
		return
	await get_tree().physics_frame
	await get_tree().physics_frame
	if data.asset_file_path != null:
		get_node("Sprite").texture = load(data.asset_file_path)
	trigger()
	if !data._get("periodic") or (data._get("finite_duration") and data._get("lifetime") == 0):
		remove()
		return
	init_cooldown_timer()
	if !data._get("finite_duration"): return
	init_life_timer()

func init_cooldown_timer():
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	add_child(cooldown_timer)
	cooldown_timer.start(data._get("cooldown"))

func init_life_timer():
	life_timer.one_shot = true
	life_timer.timeout.connect(_on_life_timer_timeout)
	add_child(life_timer)
	life_timer.start(data._get("lifetime"))

func init_debug_mode():
	debug_on = Utility.get_debug_setting("debug_mode_on") and Utility.get_debug_setting("general/show_effect_region")
	if debug_on: get_node("CollisionShape2D").modulate.a = 1
	else: get_node("CollisionShape2D").modulate.a = 0

func init_area_shape():
	var CollisionShape = get_node("CollisionShape2D")
	if area_shape is CircleShape:
		CollisionShape.shape = CircleShape2D.new()
		CollisionShape.shape.radius = Utility.to_world_space(area_shape.outer_radius)
		get_node("CollisionShape2D/Border1/rect").set_size(Vector2(CollisionShape.shape.radius, 2))
		get_node("CollisionShape2D/Border2/rect").set_size(Vector2(CollisionShape.shape.radius, 2))
		if area_shape.angle == 360:
			get_node("CollisionShape2D/Border1").modulate.a = 0
			get_node("CollisionShape2D/Border2").modulate.a = 0
		else:
			get_node("CollisionShape2D/Border1").rotation_degrees = area_shape.angle / 2
			get_node("CollisionShape2D/Border2").rotation_degrees = -area_shape.angle / 2
	elif area_shape is LineShape:
		CollisionShape.shape = SegmentShape2D.new()
		CollisionShape.shape.b = Vector2(Utility.to_world_space(area_shape.distance), 0)
		get_node("CollisionShape2D/Border1/rect").set_size(Vector2(CollisionShape.shape.b, 2))
		get_node("CollisionShape2D/Border2/rect").set_size(Vector2(CollisionShape.shape.b, 2))

func affected_sorter(a, b):
	if a.distance < b.distance:
		return true
	return false

func is_target_team_valid(team, target_team):
	if effect.target_mode == AreaEffect.target_modes.Enemies and target_team == team: return false
	elif effect.target_mode == AreaEffect.target_modes.Allies and target_team != team: return false
	return true

func trigger():
	if !active: return
	var team = trigger_buffer.triggering_caster.team
	var bodies = get_overlapping_bodies()
	for body in bodies:
		var distance = (body.position - global_position).length()
		var angle = angle_difference((body.position - global_position).angle(), rotation)
		var target = body.get_parent()
		if body is TileMapLayer: continue
		if !is_target_team_valid(team, target.data.team): continue
		var target_collision_radius = target.get_collision_radius()
		if area_shape is CircleShape and area_shape.is_in_self(distance - target_collision_radius, angle):
			if data._get("wait_for_collision_to_trigger"):
				if bodies_to_skip.has(body): continue
				bodies_to_skip.append(body)
			affected.append({"target": target, "distance": distance})
	var num_affected = affected.size()
	if data._get("targets_limit") and data._get("max_affected") > 0:
		affected.sort_custom(affected_sorter)
		var max_affected = data._get("max_affected")
		if num_affected > max_affected: num_affected = max_affected
	for i in range(num_affected):
		apply_effect(affected[i].target)
	affected.clear()
	
func apply_effect(target):
	target.trigger_buffer.triggering_caster = trigger_buffer.triggering_caster
	target.trigger_buffer.triggering_affected = target.data
	target.apply_effect(effect)

func remove():
	active = false
	emit_signal("removed")
	var animation_player = get_node("AnimationPlayer")
	animation_player.play("fade")
	await animation_player.animation_finished
	queue_free()

func _on_life_timer_timeout():
	remove()

func _on_cooldown_timer_timeout():
	trigger()

func _on_effect_region_body_entered(new_target_body: Node2D) -> void:
	if new_target_body is not TileMapLayer:
		var team = trigger_buffer.triggering_caster.team
		var target = new_target_body.get_parent()
		if !is_target_team_valid(team, target.data.team): return
	trigger()
	if data._get("one_shot"): remove()
	
