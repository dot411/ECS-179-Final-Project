class_name Unit
extends HP_Obj

const aligned_facing_arr4 = [
	["Right", -PI/4 - 0.01, PI/4 + 0.01],
	["Down", PI/4, PI*3/4],
	["Left", PI*3/4 + 0.01, -PI*3/4 - 0.01],
	["Up", -PI*3/4, -PI/4]
]
const aligned_facing_arr2 = [
	["Right", -PI/2, PI/2],
	["Left", PI/2, -PI/2]
]
var speed_multiplier:float = 1.0
var fatigued:bool = false
var key1_picked_up:bool = false
var unlocked:bool = false
var is_casting = false
var is_dead = false
var charge_from_pos:Vector2
var charge_to_pos:Vector2
var steer_state:int = randi_range(0, 1) * 2 - 1
var steer_state_cooldown:float = 0.5
var steer_state_timer:Timer = Timer.new()
var controller:UnitController
var ability_controller:AbilityController = AbilityController.new()
var nearby_enemies = []
var nearby_allies = []
var selected_item
@onready var body = $Body

func _ready() -> void:
	if data.HP == 0: data.HP = data.max_HP
	init_debug_mode()
	init_ability_controller()
	steer_state_timer.one_shot = true
	add_child(steer_state_timer)

func init_debug_mode():
	if Utility.get_debug_setting("unit/show_collision"): body.get_node("CollisionShape2D").modulate.a = 1
	else: body.get_node("CollisionShape2D").modulate.a = 0
	if Utility.get_debug_setting("game_AI/show_aggro_range"): body.get_node("ProximityArea/CollisionShape2D").modulate.a = 1
	else: body.get_node("ProximityArea/CollisionShape2D").modulate.a = 0

func init_ability_controller():
	ability_controller.caster = self
	add_child(ability_controller)

func init_sprite():
	var sprite_node = get_node("Body/Sprite")
	var sprite_frames = SpriteFrames.new()
	sprite_node.sprite_frames = sprite_frames
	add_animation(sprite_frames, "Idle", 4, 2, true)
	add_animation(sprite_frames, "Walk", 4, 4, true)
	add_animation(sprite_frames, "Death", 4, 4, false)
	if controller is Player:
		add_animation(sprite_frames, "Stab", 4, 4, false)
		add_animation(sprite_frames, "Shoot", 4, 4, false)
	elif controller is UnitAI:
		add_animation(sprite_frames, "Attack", 4, 4, false)
		add_animation(sprite_frames, "LongAttack", 8, 4, false)
	play_sprite_animation("Idle")

func add_animation(sprite_frames, anim, rows, columns, loop):
	if data.asset_path == null: return
	var sprite_sheet_path = str(data.asset_path, "/", data.asset_path.get_file(), anim, ".png")
	if controller is Player: sprite_sheet_path = str(data.asset_path, "/", anim, ".png")
	var sprite_sheet = load(sprite_sheet_path)
	if sprite_sheet == null: return
	add_subanimation(sprite_frames, anim, sprite_sheet, rows, columns, loop, "Down", 0)
	add_subanimation(sprite_frames, anim, sprite_sheet, rows, columns, loop, "Up", 1)
	add_subanimation(sprite_frames, anim, sprite_sheet, rows, columns, loop, "Right", 2)
	add_subanimation(sprite_frames, anim, sprite_sheet, rows, columns, loop, "Left", 3)

func add_subanimation(sprite_frames, _anim, sprite_sheet, rows, columns, loop, sub_anim, row):
	var sprite_node = get_node("Body/Sprite")
	var anim = str(_anim, sub_anim)
	sprite_frames.add_animation(anim)
	sprite_frames.set_animation_loop(anim, loop)
	for column in range(columns):
		var frame_texture = AtlasTexture.new()
		frame_texture.atlas = sprite_sheet
		frame_texture.region = Rect2(column * 32, row * 32, 32, 32)
		sprite_frames.add_frame(anim, frame_texture)

func get_aligned_facing(directions):
	var alignment_arr
	if directions == 4: alignment_arr = aligned_facing_arr4
	elif directions == 2: alignment_arr = aligned_facing_arr2
	var angle = get_facing_angle()
	for aligned_facing in alignment_arr:
		var start_angle = aligned_facing[1]
		var end_angle = aligned_facing[2]
		if angle >= start_angle and angle <= end_angle: return aligned_facing[0]
		if end_angle < start_angle and (angle >= start_angle or angle <= end_angle): return aligned_facing[0]
	return ""

func is_animation_movement(anim):
	if anim.contains("Idle") or anim.contains("Walk"): return true
	return false

func play_sprite_animation(anim):
	if get_sprite_animation() == anim: return
	var aligned_facing
	aligned_facing = get_aligned_facing(4)
	get_node("Body/Sprite").play(str(anim, aligned_facing))

func get_sprite_animation():
	return get_node("Body/Sprite").animation

func get_vision_radius():
	return Utility.to_world_space(data.vision)

func set_controller(_controller):
	init_debug_mode()
	if _controller is Player:
		_controller.data = data.player_data
		body.get_node("InteractZone/CollisionShape2D").shape.radius = Utility.to_world_space(_controller.data.interact_range)
		body.get_node("Sprite/ColorRect").color = Color(0, 1, 0)
		body.get_node("ProximityArea/CollisionShape2D").modulate.a = 0
		if !Utility.get_debug_setting("player/show_interact_range"): body.get_node("InteractZone/CollisionShape2D").modulate.a = 0
	elif _controller is UnitAI:
		_controller.data = data.AI_data
		if _controller.data.chase_coefficient < 0: steer_state_cooldown = 2.0
		_controller.ability_controller = ability_controller
		body.get_node("InteractZone/CollisionShape2D").modulate.a = 0
	get_node("Body/ProximityArea/CollisionShape2D").shape.radius = get_vision_radius()
	controller = _controller
	controller.name = "Controller"
	controller.unit = self
	controller.body = body
	add_child(controller)
	init_sprite()
	if _controller is Player:
		_controller.init_camera()
	render_update()

func is_collider_steer_obstacle(collider):
	if collider is TileMapLayer or StaticBody2D: return true
	if collider is CharacterBody2D and collider.get_parent().team == data.team: return true
	return false

func update_steer_state():
	steer_state *= -1
	steer_state_timer.start(steer_state_cooldown)

func finish_casting():
	is_casting = false
	if !body.get_collision_layer_value(2):
		body.set_collision_layer_value(2, true)
		body.set_collision_mask_value(2, true)
		charge_to_pos = Vector2(0, 0)

func move(dir):
	if is_dead:
		if !get_node("Body/Sprite").is_playing(): play_sprite_animation("Death")
		return
	if is_casting and ability_controller.data.stationary: return
	if charge_to_pos != Vector2(0, 0):
		var duration = ability_controller.data.channeling_track[ability_controller.current_tick].channeling_time
		body.velocity = (charge_to_pos - charge_from_pos) / duration
	else:
		body.velocity = Utility.to_world_space(dir * data.speed * speed_multiplier)
	if is_animation_movement(get_sprite_animation()):
		if body.velocity == Vector2(0, 0): play_sprite_animation("Idle")
		else: play_sprite_animation("Walk")
	var collision_occured = body.move_and_slide()
	if collision_occured:
		var body_collider = body.get_slide_collision(0).get_collider()
		if steer_state_timer.is_stopped() and is_collider_steer_obstacle(body_collider):
			update_steer_state()

func interact():
	var bodies = body.get_node("InteractZone").get_overlapping_bodies()
	for target_body in bodies:
		var target = target_body.get_parent()
		if target is InteractableObject:
			if target.name == "MatchesContainer":
				target.interact(self)
				target.matches.interact(self) # Fireplace 
			#elif unlocked:
				#target.door.door_interact(self)
			elif target.name == "key2" and key1_picked_up:
				target.interact(self)
				target.door.door_interact(self)
				unlocked = true
			elif target.name == "key1":
				key1_picked_up = true
			else:
				target.interact(self)

func use_ability(aim_pos):
	if is_dead: return
	if ability_controller == null or is_casting: return
	update_facing_angle((aim_pos - get_pos()).angle())
	if !ability_controller.can_use(): return
	if selected_item != null and selected_item is AbilityItem:
		if selected_item._get("consumable"):
			item_amount_changed(selected_item, selected_item.amount - 1)
		elif selected_item._get("cost_resource"):
			if !spend_item_based_on_name(selected_item._get("resource_name"), selected_item._get("cost_amount")):
				return
	if ability_controller.data.cast_animation != "":
		play_sprite_animation(ability_controller.data.cast_animation)
	speed_multiplier = 1.0
	ability_controller.track_caster_aim(aim_pos)
	ability_controller.use()

func change_to_ability(ability_data):
	if ability_controller == null: return
	ability_controller.bind_ability(ability_data)

func select_item(item):
	selected_item = item
	if item is not AbilityItem or item.ability_data == null: return
	change_to_ability(item.ability_data)

func spend_item_based_on_name(_name, amount):
	for item in data.inventory:
		if item.name == _name and item.amount >= amount:
			item_amount_changed(item, item.amount - amount)
			return true
	return false

func spend_item(item_data):
	return spend_item_based_on_name(item_data.name, item_data.amount)

func gain_item(_item_data):
	var item_data = _item_data.duplicate(true)
	var inventory = data.inventory
	var amount = item_data.amount
	for item in inventory: 
		if item_data.name == item.name and item.amount < item.stack_limit:
			if item.amount + amount > item.stack_limit:
				amount = clampi(item.amount + amount - item.stack_limit, 0, amount)
				item_amount_changed(item, item.stack_limit)
			else:
				item_amount_changed(item, item.amount + amount)
				return
	while amount > item_data.stack_limit:
		item_data.amount = item_data.stack_limit
		add_item_to_inventory(item_data.duplicate(true))
		amount -= item_data.stack_limit
	item_data.amount = amount
	add_item_to_inventory(item_data.duplicate(true))

func add_item_to_inventory(item):
	data.inventory.append(item)
	if controller is Player:
		Utility.get_UI_Scene().player_gains_new_item(data.inventory, item)
		if item is AbilityItem:
			select_item(item)

func item_amount_changed(item, to_amount):
	item.amount = to_amount
	if controller is Player:
		pass
		Utility.get_UI_Scene().player_item_amount_changed(data.inventory, item, to_amount)

func get_body():
	return body

func get_pos():
	return get_body().position

func get_collision_radius():
	return body.get_node("CollisionShape2D").shape.radius

func death():
	is_dead = true
	body.get_node("CollisionShape2D").set_deferred("disabled", true)
	play_sprite_animation("Death")

func HP_changed():
	super()
	render_update_HP()

func render_update():
	render_update_HP()
	render_update_fatigue()
	render_update_attack()
	render_update_ability_power()

func render_update_HP():
	if controller is Player:
		Utility.get_UI_Scene().player_HP_update_request(data.HP, data.max_HP)

func render_update_fatigue():
	if controller is Player:
		Utility.get_UI_Scene().player_fatigue_update_request(data.fatigue, data.max_fatigue, fatigued)

func render_update_attack():
	if controller is Player:
		Utility.get_UI_Scene().player_attack_attribute_update_request(data.attack)

func render_update_ability_power():
	if controller is Player:
		Utility.get_UI_Scene().player_ability_power_attribute_update_request(data.ability_power)

func accumulate_fatigue(value:FloatPoint):
	if data.fatigue >= data.max_fatigue: return false
	data.fatigue = clampf(data.fatigue + value.run(trigger_buffer), 0.0, 100.0)
	if data.fatigue == 100: fatigued = true
	render_update_fatigue()
	return true

func drop_fatigue(value:FloatPoint):
	if data.fatigue <= 0: return false
	data.fatigue = clampf(data.fatigue - value.run(trigger_buffer), 0.0, data.max_fatigue)
	if data.fatigue == 0: fatigued = false
	render_update_fatigue()
	return true

func increase_max_HP(value:Integer):
	var v = value.run(trigger_buffer)
	data.max_HP += v
	data.HP += v
	render_update_HP()
	return true

func decrease_max_HP(value:Integer):
	if data.max_HP == 1: return false
	data.max_HP -= value.run(trigger_buffer)
	if data.max_HP < 1: data.max_HP = 1
	if data.HP < data.max_HP: data.HP = data.max_HP
	render_update_HP()
	return true

func increase_attack(value:Integer):
	data.attack += value.run(trigger_buffer)
	render_update_attack()
	return true

func decrease_attack(value:Integer):
	if data.attack == 0: return false
	data.attack -= value.run(trigger_buffer)
	if data.attack < 0: data.attack = 0
	render_update_attack()
	return true

func increase_ability_power(value:Integer):
	data.ability_power += value.run(trigger_buffer)
	render_update_ability_power()
	return true

func decrease_ability_power(value:Integer):
	if data.ability_power == 0: return false
	data.ability_power -= value.run(trigger_buffer)
	if data.ability_power < 0: data.ability_power = 0
	render_update_ability_power()
	return true

func charge(distance:FloatPoint):
	if ability_controller.current_tick + 1 >= ability_controller.data.channeling_track.size(): return
	var dist = Utility.to_world_space(distance.run(trigger_buffer))
	charge_from_pos = body.position
	charge_to_pos = body.position + Vector2(dist, 0).rotated(facing_angle)
	body.set_collision_layer_value(2, false)
	body.set_collision_mask_value(2, false)

func _on_proximity_area_body_entered(new_target_body: Node2D) -> void:
	var target = new_target_body.get_parent()
	if new_target_body is not CharacterBody2D: return
	if target.data.team != data.team: nearby_enemies.append(target)
	elif new_target_body != body: nearby_allies.append(target)

func _on_proximity_area_body_exited(new_target_body: Node2D) -> void:
	var target = new_target_body.get_parent()
	if new_target_body is not CharacterBody2D: return
	if target.data.team != data.team: nearby_enemies.erase(target)
	elif new_target_body != body: nearby_allies.erase(target)

func _on_sprite_animation_finished() -> void:
	if get_sprite_animation().contains("Death"):
		queue_free()
		return
	if !is_animation_movement(get_sprite_animation()):
		if body.velocity == Vector2(0, 0): play_sprite_animation("Idle")
		else: play_sprite_animation("Walk")
