extends Node

@export var data:DebugSettingData

func _ready() -> void:
	get_tree().set_debug_collisions_hint(data.debug_mode_on)
