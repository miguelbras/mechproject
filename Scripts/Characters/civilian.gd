extends Enemy

enum State {ESCAPE, RANDOM}

var current_stamina: float 
@export var max_stamina: float = 5.0 # stamina, how much time it walks
@export var rec = 2.0 # how much time it stops

@onready var cast = $AggroRange
@onready var timer = $Timer
@onready var doot = load("res://Prefabs/Characters/doot.tscn")

var target # target to run from
var state = State.ESCAPE # escape or move in random direction
var rand_dir = Vector3.ZERO # random direction to move

func run_from_target():
	target = Util.get_closest_target(target, position, cast, "Mob")
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
	if ready_after_spawn:
		velocity = Vector3.ZERO
		if current_stamina > 0:
			if state == State.ESCAPE:
				run_from_target()
			else:
				run_direction(rand_dir)
		if slow:
			velocity *= slow_factor
		if velocity.length() > 0:
			current_stamina -= delta
			if current_stamina <= 0:
				timer.start(rec)
	if position.y > 0.58: # hardcoded value where mobs stand at
		velocity.y = -position.y * 4
	move_and_slide()

func _on_tree_exited():
	var doot_instance = doot.instantiate()
	Global.arena.add_child(doot_instance)
	doot_instance.position = self.position
	Global.arena.enemy_despawned()
	if parent_spawner != null:
		parent_spawner.current_civilians -= 1

func _on_timer_timeout():
	timer.stop()
	current_stamina = max_stamina
	state = State.RANDOM if randf() > 0.5 else State.ESCAPE
	rand_dir = Vector3(randf_range(-1,1), 0, randf_range(-1,1)).normalized()

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
	Global.arena.enemy_spawned()
	current_stamina = max_stamina
	$RandomMovementTimer.wait_time = randf_range(10, 30)
	$RandomMovementTimer.start()


func _on_random_movement_timer_timeout():
	# only start doing random movement if fully rested
	if current_stamina != max_stamina:
		return
	
	# move in random direction for random amount of time
	current_stamina = randf_range(1, 2)
	rand_dir = Vector3(randf_range(-1,1), 0, randf_range(-1,1)).normalized()
	state = State.RANDOM
	
	$RandomMovementTimer.wait_time = randf_range(10, 30)
