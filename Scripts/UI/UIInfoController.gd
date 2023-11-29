extends Control

@export var skeletonAmountLabel: RichTextLabel
@export var flyerAmountLabel: RichTextLabel

@export var villagerAmountLabel: RichTextLabel
@export var soldiersAmountLabel: RichTextLabel
@export var buildingsAmountLabel: RichTextLabel

@export var balanceOfPowerBar: TextureProgressBar
@export var timeLabel: RichTextLabel

var villagerAmount = 0
var soldierAmount = 0
var buildingAmount = 0
var skeletonAmount = 0
var flyerAmount = 0
var totalPopulation = 0
var lichPopulation = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.arena.villagerCreated.connect(addVillager)
	Global.arena.villagerKilled.connect(removeVillager)
	Global.arena.soldierCreated.connect(addSoldier)
	Global.arena.soldierKilled.connect(removeSoldier)
	Global.arena.buildingCreated.connect(addBuilding)
	Global.arena.buildingKilled.connect(removeBuilding)
	Global.arena.skeletonCreated.connect(addSkeleton)
	Global.arena.skeletonKilled.connect(removeSkeleton)
	Global.arena.flyerCreated.connect(addFlyer)
	Global.arena.flyerKilled.connect(removeFlyer)# Replace with function body.

func addVillager():
	villagerAmount += 1
	villagerAmountLabel.text = str(villagerAmount) 
	totalPopulation+=1
	updatePowerBalanceBar()

func removeVillager():
	villagerAmount -= 1
	villagerAmountLabel.text = str(villagerAmount)
	totalPopulation-=1
	updatePowerBalanceBar()

func addSoldier():
	soldierAmount += 1
	soldiersAmountLabel.text = str(soldierAmount)
	totalPopulation+=5
	updatePowerBalanceBar()
	
func removeSoldier():
	soldierAmount -= 1
	soldiersAmountLabel.text = str(soldierAmount)
	totalPopulation-=5
	updatePowerBalanceBar()
	
func addBuilding():
	buildingAmount += 1
	buildingsAmountLabel.text = str(buildingAmount)
	totalPopulation+=20
	updatePowerBalanceBar()
	
func removeBuilding():
	buildingAmount -= 1
	buildingsAmountLabel.text = str(buildingAmount)
	totalPopulation-=20
	updatePowerBalanceBar()
		
func addSkeleton():
	skeletonAmount += 1
	skeletonAmountLabel.text = str(skeletonAmount)
	totalPopulation+=1
	lichPopulation += 2
	updatePowerBalanceBar()
	
func removeSkeleton():
	skeletonAmount -= 1
	skeletonAmountLabel.text = str(skeletonAmount)
	totalPopulation-=1
	lichPopulation -= 2
	updatePowerBalanceBar()
	
func addFlyer():
	flyerAmount +=1
	flyerAmountLabel.text = str(flyerAmount)
	totalPopulation+=1
	lichPopulation += 12
	updatePowerBalanceBar()
	
func removeFlyer():
	flyerAmount -= 1
	flyerAmountLabel.text = str(flyerAmount)
	totalPopulation-=1
	lichPopulation -= 12
	updatePowerBalanceBar()
	
func updatePowerBalanceBar():
	if totalPopulation == 0:
		balanceOfPowerBar.value = 1
		return
	balanceOfPowerBar.value = lichPopulation * 100 / totalPopulation
	
func _process(delta):
	var curr_time = Time.get_ticks_msec()/1000
	var game_time = curr_time - Global.arena.start_time
	timeLabel.text = "%ds" % game_time

