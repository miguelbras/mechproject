extends Control


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/arena.tscn")

func _on_lb_button_pressed():
	# TODO: instantiate a new square showing leaderboards, etc
	pass # Replace with function body.

func _on_quit_button_pressed():
	get_tree().quit()
