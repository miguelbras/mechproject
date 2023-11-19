extends CharacterBody3D

enum Behaviour {ESCASPE, RANDOM}

@export var max_velocity = 2
@export var hp = 10
@export var sta = 2.0

@onready var cast = $ShapeCast3D
@onready var timer = $Timer
@onready var doot = load("res://Prefabs/doot.tscn")

var target = null
var behaviour = Behaviour.ESCASPE
var rand_dir = Vector3.ZERO

@onready var slow_timer = $SlowTimer
var slow_factor = 0.5
var slow = false

func run_from_target():
	target = Util.get_closest_target(target, position, cast, "mob")
	if target != null:
		var desired_velocity = (position - target.position) * max_velocity
		var steering = desired_velocity - velocity
		velocity = Util.truncate_vector(velocity + steering, max_velocity)
		velocity.y = 0
	else:
		velocity = Vector3.ZERO

func run_direction(direction: Vector3):
	var desired_velocity = direction * max_velocity
	var steering = desired_velocity - velocity
	velocity = Util.truncate_vector(velocity + steering, max_velocity)
	velocity.y = 0

func _physics_process(delta):
	velocity = Vector3.ZERO
	if sta > 0:
		if behaviour == Behaviour.ESCASPE:
			run_from_target()
		else:
			run_direction(rand_dir)
	if slow:
		velocity *= slow_factor
	if velocity.length() > 0:
		sta -= delta
		if sta <= 0:
			timer.start()
	move_and_slide()

func _on_tree_exited():
	var doot_instance = doot.instantiate()
	doot_instance.position = position
	Global.arena.add_child(doot_instance)

func _on_timer_timeout():
	timer.stop()
	sta = 2.0
	behaviour = Behaviour.RANDOM if randf() > 0.5 else Behaviour.ESCASPE
	rand_dir = Vector3(randf_range(-1,1), 0, randf_range(-1,1))
		
func take_damage(dmg: int):
	hp -= dmg
	if hp <= 0:
		queue_free()

func set_slow():
	if slow:
		slow_timer.stop()
	slow = true
	slow_timer.start()

func _on_slow_timer_timeout():
	slow = false
