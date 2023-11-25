extends Enemy

enum State {ESCAPE, RANDOM, IDLE}

var current_stamina: float 
@export var max_stamina: float = 5.0 # stamina, how much time it walks
@export var recovery_time = 2.0 # how much time it stops

@export var AggroTargetScript: Node
@onready var stamina_timer = $StaminaTimer
@onready var random_mov_timer = $RandomMovementTimer
@onready var doot = load("res://Prefabs/Characters/doot.tscn")

var target # target to run from if ESCAPE
var state = State.IDLE
var rand_dir = Vector3.ZERO # target direction if RANDOM

var process_tick_curr = 0
var process_tick_max = 10
var my_id

# sets velocity and state
func run_from_target():
	target = AggroTargetScript.target
	if target != null:
		velocity = (self.position - target.position).normalized() * max_velocity
		velocity.y = 0
		state = State.ESCAPE
	else:
		velocity = Vector3.ZERO
		state = State.IDLE

func run_direction(direction_normalized: Vector3):
	velocity = direction_normalized * max_velocity
	velocity.y = 0

func calc_velocity():
	#if process_tick_curr <= process_tick_max:
	#	process_tick_curr += 1
	#	return
	#process_tick_curr = 0

	velocity = Vector3.ZERO
	# update velocity based on state
	if current_stamina > 0:
		if state != State.RANDOM:
			run_from_target()
		else:
			run_direction(rand_dir)
	if slow:
		velocity *= slow_factor

func _physics_process(delta):
	if ready_after_spawn:
		calc_velocity()
		# if moving, decrease stamina; otherwise, prepare to rest
		if velocity != Vector3.ZERO:
			current_stamina -= delta
			if not stamina_timer.is_stopped(): # we were resting, but got interrupted
				stamina_timer.stop()
		elif stamina_timer.is_stopped(): # if standing still, prepare to rest
			stamina_timer.start(recovery_time)
			state = State.IDLE
	# gravity. hardcoded value where mobs stand at
	if position.y > 0.58:
		velocity.y = -(position.y-0.58) * 4
	move_and_slide()

func _on_tree_exited():
	var doot_instance = doot.instantiate()
	Global.arena.add_child(doot_instance)
	doot_instance.position = self.position
	Global.arena.enemy_despawned_light(my_id)
	if parent_spawner != null:
		parent_spawner.current_civilians -= 1

func _on_slow_timer_timeout():
	slow = false
	attack1_debuff.queue_free()
	attack1_debuff = null

func _on_dot_timer_timeout():
	take_damage(dot_dmg)
	dot_ticks_left -= 1
	# print(dot_ticks_left)
	if dot_ticks_left == 0:
		dot_timer.stop()
		attack2_debuff.queue_free()
		attack2_debuff = null

func _on_ready():
	my_id = Global.arena.enemy_spawned_light(self)
	current_stamina = max_stamina
	random_mov_timer.start(randf_range(10, 20))

func _on_random_movement_timer_timeout():
	# only start doing random movement if fully rested
	if current_stamina != max_stamina:
		return
	
	# move in random direction for random amount of time
	current_stamina = randf_range(1, 3)
	rand_dir = Vector3(randf_range(-1,1), 0, randf_range(-1,1)).normalized()
	state = State.RANDOM

	random_mov_timer.start(randf_range(10, 30))


func _on_stamina_timer_timeout():
	current_stamina = max_stamina
