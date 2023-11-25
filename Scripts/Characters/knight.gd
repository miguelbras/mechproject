extends Enemy

class_name Knight

@onready var rot = $RotPoint
@onready var rot_timer = $RotPoint/Timer
@onready var cooldown = $RotPoint/Timer
@onready var sword = $RotPoint/SwordArea3D
@onready var audio_player = $AudioStreamPlayer
@export var AggroTargetScript: Node
@export var AttackRange: float

var attack_range_squared: float
var slashing = false # is swinging the sword (animation)
var can_attack = false # cooldown so it does not endlessly attack
var base_rot # restore original rotation of sword
var mob_target # which mob to follow and attack

var process_tick_curr = 0
var process_tick_max = 10
var my_id

func _on_ready():
	super._ready()
	my_id = Global.arena.enemy_spawned_light(self)
	sword.set_process(false)
	base_rot = rot.basis
	attack_range_squared = AttackRange * AttackRange

func _process(delta):
	if slashing:
		rot.rotate_y(20 * delta)

func attack():
	if not slashing:
		audio_player.play()
		sword.set_process(true)
		slashing = true
		can_attack = false
		rot_timer.start()

func _on_timer_timeout():
	sword.set_process(false)
	slashing = false
	rot_timer.stop()
	rot.basis = base_rot

func calc_velocity():
	if process_tick_curr <= process_tick_max:
		process_tick_curr += 1
		return
	process_tick_curr = 0
	
	if not slashing:
		follow_enemy()
	# update_state()
	# update_animation_parameters()
	look_at_target()
	if slow:
		velocity *= slow_factor

func _physics_process(_delta):
	if ready_after_spawn:
		calc_velocity()
	if position.y > 0.58: # hardcoded value where mobs stand at
		velocity.y = -position.y * 4
	move_and_slide()

func follow_enemy():
	mob_target = AggroTargetScript.target
	# return if enemy not found
	if mob_target == null:
		velocity = Vector3.ZERO
		return
	# return if enemy already within attack range
	var mob_in_range: bool = (self.position - mob_target.position).length_squared() < attack_range_squared
	if mob_in_range:
		velocity = Vector3.ZERO
		if can_attack:
			attack()
		return
	# chase enemy
	var desired_velocity = (mob_target.position - position) * max_velocity
	var steering = desired_velocity - velocity
	velocity = Util.truncate_vector(velocity + steering, max_velocity)
	velocity.y = 0

func look_at_target():
	if mob_target != null:
		#look_at(mob_target.position, Vector3.UP, true)
		Util.look_at_target(self, mob_target.position)

func _on_cooldown_timeout():
	can_attack = mob_target != null

func _on_slow_timer_timeout():
	slow = false
	attack1_debuff.queue_free()
	attack1_debuff = null

func _on_dot_timer_timeout():
	take_damage(dot_dmg)
	dot_ticks_left -= 1
	if dot_ticks_left == 0:
		dot_timer.stop()
		attack2_debuff.queue_free()
		attack2_debuff = null

func _on_tree_exited():
	Global.arena.enemy_despawned_light(my_id)
	if parent_spawner != null:
		parent_spawner.current_knights -= 1
