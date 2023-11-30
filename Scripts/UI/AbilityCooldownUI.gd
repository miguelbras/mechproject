extends HBoxContainer

@export var ability1Circle: TextureProgressBar
@export var ability2Circle: TextureProgressBar
@export var ability3Circle: TextureProgressBar
@export var ability4Circle: TextureProgressBar
@export var UiStats: Control
@export var lich: Lich
var timePassed = 0
var timePassedQ = 0
var timePassedW = 0
var timePassedE = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()
	lich.abilityUsed.connect(startCoundtown)
	lich.abilityQUsed.connect(startCountdownQ)
	lich.abilityWUsed.connect(startCountdownW)
	lich.abilityEUsed.connect(startCountdownE)
	lich.abilityRUsed.connect(startCountdownR)

func startCoundtown():
	timePassed = 0

func startCountdownQ():
	timePassedQ = 0
	ability1Circle.value = 100

func startCountdownW():
	timePassedW = 0
	ability2Circle.value = 100

func startCountdownE():
	timePassedE = 0
	ability3Circle.value = 100
	
func startCountdownR():
	# check if zombies < 5, if so set cd...
	ability4Circle.value = 100
	pass

func reset():
	timePassed = lich.attack_cooldown_ms
	ability1Circle.value = 0
	ability2Circle.value = 0
	ability3Circle.value = 0
	ability4Circle.value = 0
	
func _process(delta):
	if is_instance_valid(lich):
		var atkCD = lich.attack_cooldown_ms
		var atkCDQ = lich.attackQ_Cooldown_ms
		var atkCDW = lich.attackW_Cooldown_ms
		var atkCDE = lich.attackE_Cooldown_ms
		if timePassedQ <= atkCDQ:
			timePassedQ += delta*1000
		if timePassedW <= atkCDW:
			timePassedW += delta*1000
		if timePassedE <= atkCDE:
			timePassedE += delta*1000
		if timePassed <= atkCD:
			timePassed += delta*1000
		var value = atkCD - timePassed
		var valueQ = atkCDQ - timePassedQ
		var valueW = atkCDW - timePassedW
		var valueE = atkCDE - timePassedE
		ability1Circle.value = (value  * 100 / atkCD if value > valueQ else valueQ  * 100 / atkCDQ)
		ability2Circle.value = (value  * 100 / atkCD if value > valueW else valueW  * 100 / atkCDW)
		ability3Circle.value = (value  * 100 / atkCD if value > valueE else valueE  * 100 / atkCDE)
		var zombies_needed = lich.flyer_summon_sacrifices - min(UiStats.skeletonAmount, lich.flyer_summon_sacrifices)
		ability4Circle.value = (zombies_needed*100.0) / lich.flyer_summon_sacrifices

