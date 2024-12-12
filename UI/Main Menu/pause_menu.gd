
extends Control


#var gamescene = load("res://Main/Game Scene/game_scene.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass







func _on_resume_pressed() -> void:
	$"..".resume_game()


func _on_save_and_exit_pressed() -> void:
	Utility.get_GameScene().exit_game()
