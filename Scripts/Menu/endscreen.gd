extends CanvasLayer

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
	if feedback_label:
		feedback_label.text = "You took %d seconds to conquer the empire!" % game_time

func _on_http_request_request_completed(result, response_code, headers, body):
	#feedback_label.text = "Submitted!"
	pass


func _on_submit_button_pressed():
	var _name = str(test_box.text)
	if len(_name) == 0:
		feedback_label.text = "Empty name!"
		return
	if len(_name) > 20:
		feedback_label.text = "Name too large!"
		return
	var json = JSON.stringify({"name": _name, "time": game_time, "secret": "quwhrksdbvieurrhrfoqiushffowiihoqusbijqwbv"})
	
	# Perform a POST request. The URL below returns JSON as of writing.
	feedback_label.text = "Submitting..."
	var error = http_requester.request("http://2.82.169.84:6969/", [], HTTPClient.METHOD_POST, json)
	if error != OK:
		feedback_label.text = "Server down..."
		return
	submit_button.disabled = true
	feedback_label.text = "Submitted!"
