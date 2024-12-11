class_name AbilityController
extends Node

var caster:Obj
var aim_pos:Vector2
var aim_angle:float
var effect_relative_pos:Vector2
var effect_pos_from_aim_point:Vector2
var effect_pos_from_caster:Vector2
var effect_angle:float
var current_tick:int = 0
var channeling_timer:Timer = Timer.new()
var cooldown_timer:Timer = Timer.new()
var data:AbilityData

func _ready() -> void:
	channeling_timer.one_shot = true
	channeling_timer.timeout.connect(tick)
	add_child(channeling_timer)
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	add_child(cooldown_timer)

func bind_ability(ability_data):
	if data != null: data.cooldown_time_left = cooldown_timer.time_left
	data = ability_data
	if data.cooldown_time_left > 0: cooldown_timer.start(data.cooldown_time_left)

func track_caster_aim(target_pos):
	aim_pos = target_pos
	aim_angle = (target_pos - caster.get_pos()).angle()

func set_effect_point(distance_modifier, angle_modifier):
	effect_angle = aim_angle + deg_to_rad(angle_modifier)
	effect_relative_pos = Vector2(Utility.to_world_space(distance_modifier), 0).rotated(effect_angle)
	effect_pos_from_caster = caster.get_body().position + effect_relative_pos
	effect_pos_from_aim_point = aim_pos + effect_relative_pos

func spawn_effect_region(data:EffectRegionData):
	var effect_region = load("res://Main/Effect/Effect Region/effect_region.tscn").instantiate()
	effect_region.trigger_buffer.triggering_caster = caster.data
	effect_region.data = data.duplicate(true)
	effect_region.rotation = effect_angle
	if data.follow_parent:
		effect_region.position = effect_relative_pos
		caster.get_body().add_child(effect_region)
	else:
		effect_region.position = effect_pos_from_aim_point
		Utility.get_GameScene().add_instance(effect_region)

func spawn_projectile(data:ProjectileData):
	var projectile = load("res://Main/Obj/Projectile/projectile.tscn").instantiate()
	#AUDIO
	var gunshot_audio = AudioStreamPlayer2D.new()
	gunshot_audio.stream = load("res://Audio/gunshot.wav")
	gunshot_audio.autoplay = false
	add_child(gunshot_audio)
	if not gunshot_audio.is_playing():
		gunshot_audio.play()
	projectile.get_node("EffectRegion").trigger_buffer.triggering_caster = caster.data
	projectile.get_node("EffectRegion").data = data.effect_region_data
	projectile.data = data.duplicate(true)
	projectile.rotation = effect_angle
	projectile.position = effect_pos_from_caster
	Utility.get_GameScene().add_instance(projectile)

func spawn_pickable_item(data:ItemData):
	var pickable_item = load("res://Main/Obj/PickableItem/PickableItem.tscn").instantiate()
	pickable_item.data = data.duplicate(true)
	pickable_item.position = effect_pos_from_caster
	Utility.get_GameScene().add_instance(data)

func spawn_unit(data:UnitData):
	var unit = load("res://Main/Obj/Unit/unit.tscn").instantiate()
	unit.data = data.duplicate(true)
	unit.data.team = 2
	for i in (unit.data.abilities).size():
		unit.data.abilities[i] = unit.data.abilities[i].duplicate(true)
	if caster is AbilityObject:
		caster.spawned_units.append(unit)
		unit.tree_exited.connect(caster._on_spawned_unit_exited)
	unit.get_node("Body").position = effect_pos_from_caster
	Utility.get_GameScene().add_instance(unit)
	unit.set_controller(UnitAI.new())

func can_use():
	if data == null: return false
	if data.channeling_track.size() == 0: return false
	if !cooldown_timer.is_stopped(): return false
	return true

func use():
	if !can_use(): return
	var intervals = data.channeling_track
	var interval = intervals[current_tick]
	if data.cooldown > 0:
		var cooldown = data.cooldown
		if caster.get_body() is CharacterBody2D and caster.controller is UnitAI:
			cooldown += randf_range(0.0, 1.0)
		data.cooldown_time_left = cooldown
		cooldown_timer.start(cooldown)
	if interval.channeling_time == 0:
		tick()
		return
	if caster is Unit:
		caster.is_casting = true
	channeling_timer.start(interval.channeling_time)

func tick():
	var intervals = data.channeling_track
	trigger(intervals[current_tick])
	current_tick += 1
	if current_tick >= intervals.size():
		finish()
		return
	if intervals[current_tick].channeling_time == 0:
		tick()
		return
	channeling_timer.start(intervals[current_tick].channeling_time)

func _on_cooldown_timer_timeout():
	data.cooldown_time_left = 0

func finish():
	if caster is Unit: caster.finish_casting()
	current_tick = 0
	channeling_timer.stop()

func refresh():
	cooldown_timer.stop()
	data.cooldown_time_left = 0

func trigger(channeling_interval:ChannelingInterval):
	caster.trigger_buffer.triggering_caster = caster.data
	if caster is Unit:
		caster.trigger_buffer.triggering_affected = caster.data
		var self_effects = channeling_interval.self_effects
		for self_effect in self_effects:
			caster.apply_effect(self_effect)
	var position_effects = channeling_interval.position_effects
	for position_effect in position_effects:
		trigger_position_effect(position_effect)

func trigger_position_effect(position_effect:PositionEffect):
	if has_method(position_effect.get_function()):
		set_effect_point(position_effect.distance_modifier, position_effect.angle_modifier)
		callv(position_effect.get_function(), position_effect.get_args().duplicate())
