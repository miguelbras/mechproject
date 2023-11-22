extends HBoxContainer

@export var ability1Circle: TextureProgressBar
@export var ability2Circle: TextureProgressBar
@export var ability3Circle: TextureProgressBar
@export var lich: Lich
var timePassed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()
	lich.abilityUsed.connect(startCoundtown)
	lich.coolDownThick.connect(update)

func startCoundtown():
	timePassed = 0
	ability1Circle.value = 100
	ability2Circle.value = 100
	ability3Circle.value = 100

func reset():
	timePassed = lich.attack_cooldown_ms
	ability1Circle.value = 0
	ability2Circle.value = 0
	ability3Circle.value = 0
	
func update(delta):
	var atkCD = lich.attack_cooldown_ms
	if timePassed <= atkCD:
		timePassed += delta*1000
		var value = atkCD - timePassed
		# print(value)
		ability1Circle.value = value * 100 / atkCD
		ability2Circle.value = value * 100 / atkCD
		ability3Circle.value = value * 100 / atkCD
	else:
		reset()
