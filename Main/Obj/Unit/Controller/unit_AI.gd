class_name UnitAI
extends UnitController

const pathfinding_raycast_count = 16
var steer_speed:float = 0.05
var targets = []
var targets_metadata = []
var pathfinding_rays = []
var direction_map = []
var interest_map = []
var home_pos:Vector2
var move_dir = Vector2(0, 0)
var wander_noise = FastNoiseLite.new()
var wander_noise_offset = Vector2(randf_range(0, 10000), randf_range(0, 10000))
var ability_controller:AbilityController
var data:UnitAIData
var zombie_music:AudioStreamPlayer2D

func _ready() -> void:
	body.get_node("Dir").visible = true
	home_pos = unit.get_pos()
	wander_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	wander_noise.frequency = 0.3
	interest_map.resize(pathfinding_raycast_count)
	var skip_raycast_initialization = false
	if body.has_node("PathfindingRaycast"):
		skip_raycast_initialization = true
		var PathfindingRaycast = body.get_node("PathfindingRaycast")
		for i in range(pathfinding_raycast_count):
			pathfinding_rays.append(PathfindingRaycast.get_child(i))
	else:
		var pathfinding_raycast = Node2D.new()
		pathfinding_raycast.name = "PathfindingRaycast"
		body.add_child(pathfinding_raycast)
	var PathfindingRaycast = body.get_node("PathfindingRaycast")
	for i in range(pathfinding_raycast_count):
		var angle = i * TAU / pathfinding_raycast_count
		var target_pos = Vector2(cos(angle), sin(angle))
		direction_map.append(target_pos)
		if skip_raycast_initialization: continue
		var raycast = RayCast2D.new()
		raycast.name = str(i)
		raycast.target_position = target_pos * unit.get_vision_radius()
		raycast.collision_mask = 0b11
		PathfindingRaycast.add_child(raycast)
		pathfinding_rays.append(raycast)
	init_debug_mode()
	#AUDIO
	var zombie_music = AudioStreamPlayer2D.new()
	zombie_music.stream = load("res://Audio/zombiemusic.wav")
	zombie_music.autoplay = false
	zombie_music.volume_db = 14
	zombie_music.name = "ZombieMusic"
	add_child(zombie_music)

func init_debug_mode():
	if Utility.get_debug_setting("game_AI/show_raycast"): body.get_node("PathfindingRaycast").modulate.a = 1
	else: body.get_node("PathfindingRaycast").modulate.a = 0
	if Utility.get_debug_setting("game_AI/show_targeting"):
		unit.get_node("AI Target").visible = true
		unit.get_node("AI Target").position = unit.get_pos()
	else: unit.get_node("AI Target").visible = false

func update_move_dir(dir):
	if move_dir == Vector2(0, 0):
		move_dir = dir
		return
	move_dir = lerp(move_dir, dir, steer_speed)
	unit.update_facing_angle(move_dir.angle())
	body.get_node("Dir").rotation = move_dir.angle()

func _physics_process(delta: float) -> void:
	if unit.nearby_enemies.size() > 0:
		var space_state = get_world_2d().direct_space_state
		for enemy in unit.nearby_enemies:
			if enemy not in targets and unit.vision_intersect_ray(space_state, unit.get_pos(), enemy.get_pos()).size() == 0:
				targets.append(enemy)
				targets_metadata.append([enemy.get_pos(), false])
	if targets.size() == 0:
		wander(delta)
		#AUDIO
		if $ZombieMusic.is_playing():
			$ZombieMusic.stop()
	else:
		if not $ZombieMusic.is_playing():
			$ZombieMusic.play()
		pathfinding_main()
		ability_casting_main()

func wander(delta):
	var wander_radius = Utility.to_world_space(data.wander_range)
	var distance_to_home = (home_pos - unit.get_pos()).length()
	var best_dir = (home_pos - unit.get_pos()).normalized()
	var increment = delta
	wander_noise_offset += Vector2(increment, increment)
	if wander_noise.offset.x > 10000: wander_noise.offset.x -= 10000
	if wander_noise.offset.y > 10000: wander_noise.offset.y -= 10000
	var noise_x = wander_noise.get_noise_2d(wander_noise_offset.x, 0)
	var noise_y = wander_noise.get_noise_2d(0, wander_noise_offset.y)
	best_dir = lerp(Vector2(noise_x, noise_y).normalized(), best_dir, (distance_to_home / wander_radius))
	interest_map.fill(0.0)
	for i in range(direction_map.size()):
		var dir = direction_map[i]
		var alignment_weight = max(-1.0, best_dir.dot(dir))
		interest_map[i] += alignment_weight
	separation_from_allies()
	best_dir = direction_map[interest_map.find(interest_map.max())]
	update_move_dir(best_dir)
	unit.move(move_dir)
	unit.get_node("AI Target").position = unit.get_pos()

func pathfinding_main():
	var space_state = get_world_2d().direct_space_state
	interest_map.fill(0.0)
	var no_live_target = true
	for i in range(targets.size() - 1, -1, -1):
		var target_metadata = targets_metadata[i]
		var enemy = targets[i]
		if enemy == null or unit.get_pos().distance_to(enemy.get_pos()) > unit.get_vision_radius() + enemy.get_vision_radius():
			targets.remove_at(i)
			targets_metadata.remove_at(i)
			continue
		var target_LOS_blocked = unit.vision_intersect_ray(space_state, unit.get_pos(), enemy.get_pos()).size() > 0
		target_metadata[1] = target_LOS_blocked
		if !target_LOS_blocked:
			no_live_target = false
			target_metadata[0] = enemy.get_pos()
			unit.get_node("AI Target").position = enemy.get_pos()
	if targets.size() == 0: return
	if no_live_target:
		seek_closest_last_seen()
	else:
		balance_steer_state_from_allies()
		pursue()
		separation_from_allies()
		var best_dir = direction_map[interest_map.find(interest_map.max())]
		update_move_dir(best_dir)
		unit.move(move_dir)

func seek_closest_last_seen():
	var closest_i = 0
	var enemy_position = targets_metadata[closest_i][0]
	var prev_distance = (enemy_position - unit.get_pos()).length()
	for i in range(1, targets.size()):
		var target_metadata = targets_metadata[i]
		var enemy = targets[i]
		enemy_position = target_metadata[0]
		var distance_to_enemy = (enemy_position - unit.get_pos()).length()
		if distance_to_enemy < prev_distance:
			closest_i = i
			prev_distance = distance_to_enemy
	enemy_position = targets_metadata[closest_i][0]
	var direction_to_enemy = (enemy_position - unit.get_pos()).normalized()
	for i in range(direction_map.size()):
		var dir = direction_map[i]
		var raycast = pathfinding_rays[i]
		var collider = raycast.get_collider()
		var collision_point = raycast.get_collision_point()
		var alignment_weight = max(-1.0, direction_to_enemy.dot(dir))
		interest_map[i] += alignment_weight
		if collider is TileMapLayer and (collision_point - unit.get_pos()).length() < Utility.to_world_space(0.5):
			var tile_pos = Utility.get_tile_position(collider.position)
			var distance_weight = clamp(Utility.to_world_space(0.5) / max(1.0, (tile_pos - unit.get_pos()).length()), 0.0, 1.0)
			interest_map[i] -= distance_weight
	var best_dir = direction_map[interest_map.find(interest_map.max())]
	update_move_dir(best_dir)
	unit.move(move_dir)
	if (enemy_position - unit.get_pos()).length() < Utility.to_world_space(0.5):
		home_pos = unit.get_pos()
		targets.clear()

func pursue():
	var steer_state = unit.steer_state
	for i in range(targets.size()):
		var target_metadata = targets_metadata[i]
		var enemy = targets[i]
		var enemy_position = target_metadata[0]
		var direction_to_enemy = (enemy_position - unit.get_pos()).normalized()
		var distance_to_enemy = (enemy_position - unit.get_pos()).length()
		for j in range(direction_map.size()):
			var dir = direction_map[j]
			var raycast = pathfinding_rays[j]
			var collider = raycast.get_collider()
			var collision_point = raycast.get_collision_point()
			var alignment_weight = max(-1.0, direction_to_enemy.dot(dir))
			interest_map[j] += alignment_weight * data.chase_coefficient
			var sideway_weight = max(-1.0, direction_to_enemy.cross(dir)) * steer_state
			var dist_proportion = 1.0 - distance_to_enemy / unit.get_vision_radius()
			interest_map[j] += sideway_weight * data.surround_coefficient * dist_proportion
			if collider is TileMapLayer and (collision_point - unit.get_pos()).length() < Utility.to_world_space(0.5):
				var distance_weight = clamp(Utility.to_world_space(0.5) / max(1.0, (collision_point - unit.get_pos()).length()), 0.0, 1.0)
				interest_map[j] -= distance_weight

func balance_steer_state_from_allies():
	if !unit.steer_state_timer.is_stopped(): return
	var steer_state = unit.steer_state
	var same_steer_state_count = 0
	for i in range(unit.nearby_allies.size()):
		var ally = unit.nearby_allies[i]
		if ally.steer_state == steer_state:
			same_steer_state_count += 1
	if same_steer_state_count > floor(0.7 * unit.nearby_allies.size()):
		unit.update_steer_state()

func separation_from_allies():
	for i in range(unit.nearby_allies.size()):
		var ally = unit.nearby_allies[i]
		var direction_to_ally = (ally.get_pos() - unit.get_pos()).normalized()
		var distance_to_ally = (ally.get_pos() - unit.get_pos()).length()
		for j in range(direction_map.size()):
			var dir = direction_map[j]
			var alignment_weight = max(-1.0, direction_to_ally.dot(dir))
			var distance_weight = clamp(Utility.to_world_space(0.5) / max(1.0, distance_to_ally), 0.0, 1.0)
			interest_map[j] -= alignment_weight * distance_weight / (1 + (unit.nearby_allies.size() - 1) * 0.4)

func ability_casting_main():
	if targets.size() == 0: return
	var available_abilities = get_available_abilities()
	if available_abilities.size() == 0: return
	var ability = available_abilities[0]
	var closest_aim = targets_metadata[0][0]
	for _metadata in targets_metadata:
		if _metadata[0] >= closest_aim: continue
		closest_aim = _metadata[0]
	var distance = (closest_aim - unit.get_pos()).length()
	if Utility.to_world_space(ability.AI_cast_range) < distance: return
	unit.change_to_ability(ability)
	unit.use_ability(closest_aim)

func abilities_sorter(a, b):
	if a.AI_cast_range < b.AI_cast_range:
		return true
	return false

func get_available_abilities():
	var available_abilities = []
	for ability in unit.data.abilities:
		if ability.cooldown_time_left != 0: continue
		available_abilities.append(ability)
	available_abilities.sort_custom(abilities_sorter)
	return available_abilities
