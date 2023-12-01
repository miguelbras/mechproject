extends Control

@export var text_label: RichTextLabel
@onready var timer: Timer = $Timer

var current_tutorial_index = 0
var hints = [
	"                Try moving around with your Right Mouse Button!",
	"                                 Cast your spells with QWE!",
	"                      Order your undead to follow you with SPACE!",
	"                   Order your undead to attack with Left Mouse Button!",
	"              Summon a stronger undead by sacrificing 5 followers with R!",
	"                          Some enemies fight back, be careful!",
	"       Conquer the empire as fast as possible to get on the leaderboards!",
]

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.start(10)
	text_label.visible = false
	
func set_text(text: String):
	text_label.clear()
	text_label.push_color(Color.WHITE)
	#text_label.push_align(1)
	text_label.append_text(text)
	#text_label.pop()  # Ends the tag opened by push_align()`.
	text_label.pop()  # Ends the tag opened by `push_color()`.

func _on_timer_timeout():
	text_label.visible = not text_label.visible
	if text_label.visible:
		set_text(hints[current_tutorial_index])
		timer.start(10)
		current_tutorial_index += 1
	else:
		if current_tutorial_index < len(hints):
			timer.start(20)
