
extends Control


#var gamescene = load("res://Main/Game Scene/game_scene.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
		Utility.get_GameScene().new_game("res://Levels/Maps/start_level.tscn")
		#$"../in_game_control".visible = true
		#$".".visible = true
		$"..".start_game_ui()

func _on_save_and_exit_pressed():
	Utility.get_GameScene().load_game()
	$"..".start_game_ui()

func _on_exit_pressed() -> void:
	get_tree().quit()





func _on_load_game_pressed() -> void:
	Utility.get_GameScene().load_game()
