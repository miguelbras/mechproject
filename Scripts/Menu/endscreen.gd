extends Node3D


func _on_quit_button_pressed():
	get_tree().quit()

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
