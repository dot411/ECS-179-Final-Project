class_name GameScene
extends Node

var save_data:SaveGameData = SaveGameData.new()
var current_map_node:Node2D
var player_node:Unit

#func _ready() -> void:
	#new_game("res://Levels/Maps/start_level.tscn")

func go_to_map(path_resource, pos):
	var path = path_resource.path
	save_data.player.pos = pos
	load_map(path)

func load_map(path):
	if current_map_node != null:
		get_node("Instances").queue_free()
		await(get_node("Instances").tree_exited)
		current_map_node.queue_free()
		await current_map_node.tree_exited
	var instances_node = Node2D.new()
	instances_node.name = "Instances"
	add_child(instances_node)
	var map = load(path).instantiate()
	current_map_node = map
	add_child(map)
	if player_node == null:
		var unit_scene = load("res://Main/Obj/Unit/unit.tscn")
		var player_inst = unit_scene.instantiate()
		if save_data.player.size() > 0:
			player_inst.data = save_data.player.data
			player_inst.get_node("Body").position = save_data.player.pos
		elif map.has_node("StartingPlayer"):
			player_inst.data = map.get_node("StartingPlayer").unit_data
			player_inst.get_node("Body").position = map.get_node("StartingPlayer").position
			map.get_node("StartingPlayer").queue_free()
			player_inst.data.team = 1
		add_child(player_inst)
		player_inst.set_controller(Player.new())
		player_node = player_inst
		save_data.player = {"pos": player_inst.position, "data": player_inst.data}
	else:
		player_node.get_body().position = save_data.player.pos
		if map.has_node("StartingPlayer"): map.get_node("StartingPlayer").queue_free()
	if save_data.save_dictionary.has(path):
		var map_data = save_data.save_dictionary[path]
		for child_path in map_data.keys():
			map.get_node(child_path).data = map_data[child_path]
	else:
		save_data.save_dictionary[path] = {}
		store_map_data(map, path)
	save_data.current_map_path = path
	var map_data = save_data.save_dictionary[path]
	await get_tree().create_timer(0.01).timeout
	for child_path in map_data.keys():
		var child = map.get_node(child_path)
		if child.has_method("init"): child.init()

func new_game(path):
	load_map(path)

func exit_game():
	#save_game()
	current_map_node.queue_free()
	player_node.queue_free()
	player_node = null
	save_data = SaveGameData.new()
	var UI_scene = Utility.get_UI_Scene()
	UI_scene.hide_ingame_control()

func store_map_data(map, map_path):
	var map_data = save_data.save_dictionary[map_path]
	var children = map.get_children()
	for child in children:
		if child.get("data") == null: continue
		var node_path = map.get_path_to(child)
		map_data[node_path] = child.data

func save_game():
	save_data.player.data = {"data": player_node.data}
	var save_path = "res://save_game.tres"
	ResourceSaver.save(save_data, save_path, ResourceSaver.FLAG_BUNDLE_RESOURCES)

func load_game():
	var save_path = "res://save_game.tres"
	if FileAccess.file_exists(save_path):
		save_data = ResourceLoader.load(save_path)
		var unit_scene = load("res://Main/Obj/Unit/unit.tscn")
		var player_inst = unit_scene.instantiate()
		player_inst.data = save_data.player.data
		player_inst.get_node("Body").position = save_data.player.pos
		add_child(player_inst)
		player_inst.set_controller(Player.new())
		player_node = player_inst
	else: new_game("res://Levels/Maps/start_level.tscn")

func add_instance(instance):
	get_node("Instances").add_child(instance)
