extends Enemy

class_name Knight

@export var attack_range: float
@export var strength = 3

@onready var audio_player = $AudioStreamPlayer
@onready var cooldown = $Cooldown
@onready var AggroTargetScript = $Thread1Node

var attack_range_squared: float
var can_attack = true # cooldown so it does not endlessly attack
var attacking = false
var base_rot # restore original rotation of sword
var mob_target # which mob to follow and attack

var process_tick_curr = 0
var process_tick_max = 10
var my_id

func _ready():
	super._ready()
	my_id = Global.arena.enemy_spawned_light(self)
	attack_range_squared = attack_range * attack_range

func attack():
	cooldown.start()
	audio_player.play()
	mob_target.take_damage(strength)
	can_attack = false
	attacking = true

func calc_velocity():
	if process_tick_curr <= process_tick_max:
		process_tick_curr += 1
		return
	process_tick_curr = 0
	
	if not attacking:
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
	mob_target = AggroTargetScript.closest_target
	# return if enemy not found
	#print(mob_target)
	if mob_target == null:
		velocity = Vector3.ZERO
		return
	# return if enemy already within attack range
	var mob_in_range: bool = (self.position - mob_target.position).length_squared() < attack_range_squared
	#print(name, " ", mob_in_range)
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
		Util.look_at_target(self, mob_target.position)

func _on_cooldown_timeout():
	can_attack = true
	attacking = false

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
