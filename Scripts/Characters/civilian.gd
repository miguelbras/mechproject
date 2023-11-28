extends Enemy

enum State {ESCAPE, RANDOM, IDLE, DEAD}

var current_stamina: float 
@export var max_stamina: float = 5.0 # stamina, how much time it walks
@export var recovery_time = 2.0 # how much time it stops

@onready var AggroTargetScript = $Thread1Node
@onready var stamina_timer = $StaminaTimer
@onready var random_mov_timer = $RandomMovementTimer
@onready var doot = load("res://Prefabs/Characters/doot.tscn")
@onready var fbx = $villager_female
@onready var anim_tree = $AnimationTree

var target # target to run from if ESCAPE
var state = State.IDLE
var rand_dir = Vector3.ZERO # target direction if RANDOM

var process_tick_curr = 0
@export var process_tick_max: int
var my_id

const anim_map = {
	State.ESCAPE: "metarig_001|idle_female", 
	State.RANDOM: "metarig_001|idle_female",
	State.IDLE: "metarig_001|move",
	State.DEAD: "metarig_001|death"
}

func _ready():
	super._ready()
	set_visuals(false)
	
func set_visuals(enable: bool):
	fbx.set_process(enable)
	fbx.visible = enable
	anim_tree.active = enable

# sets velocity and state
func run_from_target():
	target = AggroTargetScript.closest_target
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
	if process_tick_curr <= process_tick_max:
		process_tick_curr += 1
		return
	process_tick_curr = 0

	self.velocity = Vector3.ZERO
	# update velocity based on state
	if current_stamina > 0:
		if state != State.RANDOM:
			run_from_target()
		else:
			run_direction(rand_dir)
	if self.velocity != Vector3.ZERO:
		Util.look_at_target(self, self.position + self.velocity)
	if slow:
		self.velocity *= slow_factor

func _process(delta):
	update_state()
	update_animation_parameters()

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
	if position.y > 0.59:
		velocity.y = -(position.y-0.59) * 4
	move_and_slide()

func _on_tree_exited():
	var doot_instance = doot.instantiate()
	Global.arena.add_child.call_deferred(doot_instance)
	doot_instance.position = self.position
	Global.arena.enemy_despawned(my_id, false)
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
	my_id = Global.arena.enemy_spawned(self, false)
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


func _on_visible_on_screen_notifier_3d_screen_entered():
	set_visuals(true)
	anim_tree["parameters/playback"].start(anim_map[state])

func _on_visible_on_screen_notifier_3d_screen_exited():
	set_visuals(false)

func update_state():
	if hp <= 0:
		state = State.DEAD

func update_animation_parameters():
	anim_tree["parameters/conditions/idle"] = state == State.IDLE
	anim_tree["parameters/conditions/move"] = state == State.ESCAPE or state == State.RANDOM
	anim_tree["parameters/conditions/death"] = state == State.DEAD
