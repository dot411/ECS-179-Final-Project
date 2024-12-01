extends Node

func get_GameScene():
	return get_node("/root/World/GameScene")

func get_UI_Scene():
	return get_node("/root/World/Static Canvas/UI")

func get_player_node():
	return get_GameScene().player_node

func get_debug_setting(option):
	var data = get_UI_Scene().get_node("Debug Setting").data
	if !data._get("debug_mode_on"): return false
	return data._get(option)

func get_TriggerContext():
	return get_GameScene().get_node("TriggerContext")

func to_world_space(value):
	return value * SystemConstants.cell_resolution

func get_tile_position(pos):
	return pos + to_world_space(Vector2(0.5, 0.5))
