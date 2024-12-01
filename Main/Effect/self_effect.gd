@tool
class_name SelfEffect
extends Effect

func _init() -> void:
	init_categories()
	add_functions(["charge", "take_damage", "heal", "accumulate_fatigue", "drop_fatigue", "increase_max_HP", "decrease_max_HP", "increase_attack", "decrease_attack", "increase_ability_power", "decrease_ability_power"], Unit.new(), 0)
