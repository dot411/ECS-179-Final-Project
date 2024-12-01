class_name CircleShape
extends AreaShape

@export_range(0.0, 20.0, 0.01) var outer_radius:float = 1.0
@export_range(0.0, 20.0, 0.01) var inner_radius:float = 0.0
@export_range(0.0, 360.0, 0.01) var angle:float = 360.0

func is_in_self(distance, target_angle):
	var angle_limit = deg_to_rad(angle / 2)
	if distance >= Utility.to_world_space(inner_radius) and abs(target_angle) <= angle_limit:
		return true
	return false
		
