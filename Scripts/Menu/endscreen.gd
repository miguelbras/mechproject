extends Node3D

@onready var http_requester = $HTTPRequest
@export var test_box: LineEdit
@export var submit_button: Button
@export var feedback_label: Label

func _on_quit_button_pressed():
	get_tree().quit()

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


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
	var json = JSON.stringify({"name": name, "time": 10000, "secret": "quwhrksdbvieurrhrfoqiushffowiihoqusbijqwbv"})
	
	# Perform a POST request. The URL below returns JSON as of writing.
	var error = http_requester.request("http://127.0.0.1:8080", [], HTTPClient.METHOD_POST, json)
	if error != OK:
		feedback_label.text = "Server down..."
		push_error("An error occurred in the HTTP request.")
		return
	submit_button.disabled = true
	feedback_label.text = "Submitted!"
