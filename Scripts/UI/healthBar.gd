extends Control

@export var lich: Lich
@export var pg_bar: TextureProgressBar
@export var time_label: Label

func _ready():
	# print("ready")
	update()
	lich.healthChanged.connect(update)

func _process(delta):
	var curr_time = Time.get_ticks_msec()/1000
	var game_time = curr_time - Global.arena.start_time
	time_label.text = "%ds" % game_time

func update():
	pg_bar.value = lich.hp * 100 / lich.maxHp
	# print(lich.hp)
	# print(value)
