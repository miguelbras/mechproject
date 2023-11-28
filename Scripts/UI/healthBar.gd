extends Control

@export var lich: Lich
@export var pg_bar: TextureProgressBar

func _ready():
	# print("ready")
	update()
	lich.healthChanged.connect(update)

func update():
	pg_bar.value = lich.hp * 100 / lich.maxHp
	# print(lich.hp)
	# print(value)
