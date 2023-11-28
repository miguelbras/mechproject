extends Control

@onready var http_requester = $HTTPRequest
@export var text_label: RichTextLabel

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_map.tscn")

func _on_lb_button_pressed():
	# Perform a GET request. The URL below returns JSON as of writing.
	var error = http_requester.request("http://2.82.169.84:6969/")
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_http_request_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("HTTP error: ", result, ", response code: ", response_code)
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	var text = ""
	if "values" not in json:
		return
	var rank = 1
	for score in json["values"]:
		text += "#%03d: [b]%20s[/b] - %05ds\n" % [rank, score["name"], score["time"]]
		rank += 1
	text_label.text = "[right]%s[/right]" % text
	text_label.visible = true


func _on_credits_button_pressed():
	var text = "\n\nAdriano 'Danny Boy' Portugal\n\nDavid 'BlueMoon93' Simões\n\nMiguel 'XBlaze' Brás\n\nMiguel 'Meduzen' Mendes\n\nSimão 'DracoStriker' Reis"
	text_label.text = "[center]%s[/center]" % text
	text_label.visible = true


func _on_controls_button_pressed():
	var text = "Right Mouse Button - Move Lich\nQ - Frost Shock\nW - Fire Bolt\nE - Arcane Explosion\nR - Ritual Sacrifice\n\nLeft Mouse Button - Move Zombies\nSpace - Zombies Follow Lich\n\nTAB - Change Camera\nMouse Wheel - Zoom In/Out"
	text_label.text = "[center]%s[/center]" % text
	text_label.visible = true
