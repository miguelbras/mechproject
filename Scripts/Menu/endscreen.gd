extends Node3D

@onready var http_requester = $HTTPRequest
@export var test_box: LineEdit
@export var submit_button: Button
@export var feedback_label: Label

var game_time: int

func _on_quit_button_pressed():
	get_tree().quit()

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _ready():
	var curr_time = Time.get_ticks_msec()/1000
	game_time = curr_time - Global.arena.start_time
	feedback_label.text = "You took %d seconds to conquer the empire!" % game_time

func _on_http_request_request_completed(result, response_code, headers, body):
	pass # Replace with function body.


func _on_submit_button_pressed():
	var name = str(test_box.text)
	if len(name) == 0:
		feedback_label.text = "Empty name!"
		return
	if len(name) > 20:
		feedback_label.text = "Name too large!"
		return
	var json = JSON.stringify({"name": name, "time": game_time, "secret": "quwhrksdbvieurrhrfoqiushffowiihoqusbijqwbv"})
	
	# Perform a POST request. The URL below returns JSON as of writing.
	var error = http_requester.request("http://2.82.169.84:6969/", [], HTTPClient.METHOD_POST, json)
	if error != OK:
		feedback_label.text = "Server down..."
		push_error("An error occurred in the HTTP request.")
		return
	submit_button.disabled = true
	feedback_label.text = "Submitted!"
