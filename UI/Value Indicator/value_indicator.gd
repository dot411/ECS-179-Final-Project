class_name ValueIndicator
extends Control



func update_health(current_hp:int , max_hp:int):
	var health_bar = $HealthBar
	if health_bar:
		health_bar.value = current_hp
		print(health_bar.value)
		health_bar.max_value = max_hp

func update_fatigue(current_fatigue: float, max_fatigue: float, fatigued:bool):
	var fatigue_bar = $FatigueBar
	if fatigue_bar:
		fatigue_bar.value = current_fatigue
		fatigue_bar.max_value = max_fatigue
	#if fatigued:
		#fatigue_bar.add_color_override("fg_color", Color(1, 0, 0))  # Red for fatigued
	#else:
		#fatigue_bar.add_color_override("fg_color", Color(0, 0, 1))  # Red for fatigued
