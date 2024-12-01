@tool
class_name AreaEffect
extends Effect

enum target_modes {
	Enemies,
	Allies
}

@export var target_mode:target_modes

func _init() -> void:
	init_categories()
	add_functions(["take_damage", "heal", "accumulate_fatigue", "drop_fatigue", "increase_max_HP", "decrease_max_HP", "increase_attack", "decrease_attack", "increase_ability_power", "decrease_ability_power"], Unit.new(), 0)
