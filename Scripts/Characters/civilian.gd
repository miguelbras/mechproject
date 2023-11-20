extends CharacterBody3D

enum State {ESCAPE, RANDOM}

@export var max_velocity = 2
@export var hp = 10
@export var sta = 5.0
@export var rec = 2.0

@onready var cast = $ShapeCast3D
@onready var timer = $Timer
@onready var doot = load("res://Prefabs/Characters/doot.tscn")

var target = null
var state = State.ESCAPE
var rand_dir = Vector3.ZERO

@onready var slow_timer = $SlowTimer
var slow_factor = 0.5
var slow = false
@export var attack1_debuff_prefab : PackedScene
var attack1_debuff = null

@onready var dot_timer = $DotTimer
var dot_tick_count_max = 5
var dot_ticks_left = 0
var dot_dmg = 1
@export var attack2_debuff_prefab : PackedScene
var attack2_debuff = null

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
		if state == State.ESCAPE:
			run_from_target()
		else:
			run_direction(rand_dir)
	if slow:
		velocity *= slow_factor
	if velocity.length() > 0:
		sta -= delta
		if sta <= 0:
			timer.start(rec)
	move_and_slide()

func _on_tree_exited():
	var doot_instance = doot.instantiate()
	doot_instance.position = position
	Global.arena.add_child(doot_instance)
	Global.arena.enemy_despawned()

func _on_timer_timeout():
	timer.stop()
	sta = 2.0
	state = State.RANDOM if randf() > 0.5 else State.ESCAPE
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
	if attack1_debuff == null:
		attack1_debuff = attack1_debuff_prefab.instantiate()
		add_child(attack1_debuff)

func _on_slow_timer_timeout():
	slow = false
	attack1_debuff.queue_free()
	attack1_debuff = null

func set_dot():
	if dot_ticks_left > 0:
		dot_timer.stop()
	dot_ticks_left = dot_tick_count_max
	dot_timer.start()
	if attack2_debuff == null:
		attack2_debuff = attack2_debuff_prefab.instantiate()
		add_child(attack2_debuff)
	

func _on_dot_timer_timeout():
	take_damage(dot_dmg)
	dot_ticks_left -= 1
	# print(dot_ticks_left)
	if dot_ticks_left == 0:
		dot_timer.stop()
		attack2_debuff.queue_free()
		attack2_debuff = null


func _on_ready():
	Global.arena.enemy_spawned()
