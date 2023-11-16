extends CharacterBody3D

@export var max_velocity = 2
@export var hp = 10
@export var sta = 2.0

@onready var cast = $ShapeCast3D
@onready var timer = $Timer
@onready var doot = load("res://Prefabs/doot.tscn")

var target = null

func run_from_target():
	target = Util.get_closest_target(target, position, cast, "mob")
	if target != null:
		var desired_velocity = (position - target.position) * max_velocity
		var steering = desired_velocity - velocity
		velocity = Util.truncate_vector(velocity + steering, max_velocity)
		velocity.y = 0
	else:
		velocity = Vector3.ZERO

func _physics_process(delta):
	if sta > 0:
		run_from_target()
	if velocity.length() > 0:
		sta -= delta
		print(sta)
		if sta <= 0:
			velocity = Vector3.ZERO
			timer.start()
	move_and_slide()

func _on_tree_exited():
	var doot_instance = doot.instantiate()
	doot_instance.position = position
	Global.arena.add_child(doot_instance)

func _on_timer_timeout():
	timer.stop()
	sta = 2.0
