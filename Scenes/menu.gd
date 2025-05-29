extends Control

var level = "res://Scenes/Game.tscn"

func _on_start_button_click_end() -> void:
	var _level = get_tree().change_scene_to_file(level)


func _on_quit_button_2_click_end() -> void:
	get_tree().quit()
