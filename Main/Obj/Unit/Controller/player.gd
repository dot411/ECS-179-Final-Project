class_name Player
extends UnitController

var data = PlayerData

func init_camera():
	if !body.has_node("UnitCamera"): body.add_child(load("res://Main/Lighting/unit_camera.tscn").instantiate())
	body.get_node("UnitCamera").make_current()
	body.get_node("UnitCamera/Light").texture_scale = unit.data.vision

func _physics_process(delta: float) -> void:
	var dir = Vector2(0, 0)
	if Input.is_action_just_pressed("interact"): unit.interact()
	if Input.is_action_pressed("left"): dir.x = -1
	if Input.is_action_pressed("right"): dir.x = 1
	if Input.is_action_pressed("up"): dir.y = -1
	if Input.is_action_pressed("down"): dir.y = 1
	if !unit.is_casting:
		if Input.is_action_pressed("run") and !unit.fatigued:
			unit.accumulate_fatigue(FloatPoint.new(data.run_fatigue_drain_per_second * delta))
			unit.speed_multiplier = data.run_speed_multiplier
		else:
			unit.drop_fatigue(FloatPoint.new(data.fatigue_recovery_per_second * delta))
			unit.speed_multiplier = lerp(unit.speed_multiplier, 1.0, 0.1)
	dir = dir.normalized()
	if dir != Vector2(0, 0): unit.update_facing_angle(dir.angle())
	if Input.is_action_just_pressed("left_click"):
		unit.use_ability(get_global_mouse_position())
	unit.move(dir)
