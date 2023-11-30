extends Node3D

@export var lifeTimeMs = 2000 
var startTime = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	startTime = Time.get_ticks_msec()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Time.get_ticks_msec() - startTime) >= lifeTimeMs:
		queue_free()
	
