extends TextureProgressBar

@export var lich: Lich

func _ready():
	print("ready")
	update()
	lich.healthChanged.connect(update)

func update():
	value = lich.hp * 100 / lich.maxHp
	print(lich.hp)
	print(value)
