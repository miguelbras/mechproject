extends Control

@export var skeletonAmountLabel: RichTextLabel
@export var flyerAmountLabel: RichTextLabel

@export var villagerAmountLabel: RichTextLabel
@export var soldiersAmountLabel: RichTextLabel
@export var buildingsAmountLabel: RichTextLabel

@export var balanceOfPowerBar: TextureProgressBar
@export var timeLabel: RichTextLabel

@export var arena: Arena

var villagerAmount = 0
var soldierAmount = 0
var buildingAmount = 0
var skeletonAmount = 0
var flyerAmount = 0
var totalPopulation = 0
var lichPopulation = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	arena.villagerCreated.connect(addVillager)
	arena.villagerKilled.connect(removeVillager)
	arena.soldierCreated.connect(addSoldier)
	arena.soldierKilled.connect(removeSoldier)
	arena.buildingCreated.connect(addBuilding)
	arena.buildingKilled.connect(removeBuilding)
	arena.skeletonCreated.connect(addSkeleton)
	arena.skeletonKilled.connect(removeSkeleton)
	arena.flyerCreated.connect(addFlyer)
	arena.flyerKilled.connect(removeFlyer)# Replace with function body.

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
	totalPopulation+=1
	updatePowerBalanceBar()
	
func removeSoldier():
	soldierAmount -= 1
	soldiersAmountLabel.text = str(soldierAmount)
	totalPopulation-=1
	updatePowerBalanceBar()
	
func addBuilding():
	buildingAmount += 1
	buildingsAmountLabel.text = str(buildingAmount)
	totalPopulation+=1
	updatePowerBalanceBar()
	
func removeBuilding():
	buildingAmount -= 1
	buildingsAmountLabel.text = str(buildingAmount)
	totalPopulation-=1
	updatePowerBalanceBar()
		
func addSkeleton():
	skeletonAmount += 1
	skeletonAmountLabel.text = str(skeletonAmount)
	totalPopulation+=1
	lichPopulation += 1
	updatePowerBalanceBar()
	
func removeSkeleton():
	skeletonAmount -= 1
	skeletonAmountLabel.text = str(skeletonAmount)
	totalPopulation-=1
	lichPopulation -= 1
	updatePowerBalanceBar()
	
func addFlyer():
	flyerAmount +=1
	flyerAmountLabel.text = str(flyerAmount)
	totalPopulation+=1
	lichPopulation += 1
	updatePowerBalanceBar()
	
func removeFlyer():
	flyerAmount -= 1
	flyerAmountLabel.text = str(flyerAmount)
	totalPopulation-=1
	lichPopulation -= 1
	updatePowerBalanceBar()
	
func updatePowerBalanceBar():
	balanceOfPowerBar.value = lichPopulation * 100 / totalPopulation
	
func _process(delta):
	var curr_time = Time.get_ticks_msec()/1000
	var game_time = curr_time - Global.arena.start_time
	timeLabel.text = "%ds" % game_time
