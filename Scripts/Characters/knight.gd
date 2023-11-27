extends Enemy

class_name Knight

enum State {IDLE, WALK, ATK, DEAD}

@export var attack_range: float
@export var strength = 3

@onready var audio_player = $AudioStreamPlayer
@onready var cooldown = $Cooldown
@onready var AggroTargetScript = $Thread1Node
@onready var anim_tree = $AnimationTree
@onready var fbx = $knight

var attack_range_squared: float
var can_attack = true # cooldown so it does not endlessly attack
var attacking = false
var base_rot # restore original rotation of sword
var mob_target # which mob to follow and attack
var state = State.IDLE
var process_tick_curr = 0
@export var process_tick_max: int
var my_id

func _ready():
	super._ready()
	my_id = Global.arena.enemy_spawned(self)
	attack_range_squared = attack_range * attack_range
	set_visuals(false)

func set_visuals(enable: bool):
	fbx.set_process(enable)
	fbx.visible = enable
	anim_tree.active = enable


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
	if not attacking and hp > 0:
		follow_enemy()
	elif hp <= 0:
		velocity = Vector3.ZERO
	if slow:
		velocity *= slow_factor

func _physics_process(_delta):
	if ready_after_spawn:
		calc_velocity()
	if position.y > 0.58: # hardcoded value where mobs stand at
		velocity.y = -position.y * 4
	update_state()
	update_animation_parameters()
	look_at_target()
	move_and_slide()

func follow_enemy():
	mob_target = AggroTargetScript.closest_target
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
	Global.arena.enemy_despawned(my_id)
	if parent_spawner != null:
		parent_spawner.current_knights -= 1

func update_state():
	if hp <= 0:
		state = State.DEAD
	elif velocity != Vector3.ZERO:
		state = State.WALK
	elif velocity == Vector3.ZERO:
		if mob_target != null:
			if attacking:
				state = State.ATK
			else:
				state = State.IDLE
		else:
			state = State.IDLE

func update_animation_parameters():
	if state == State.IDLE:
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/move"] = false
		anim_tree["parameters/conditions/attack"] = false
	elif state == State.WALK:
		anim_tree["parameters/conditions/idle"] = false
		anim_tree["parameters/conditions/move"] = true
		anim_tree["parameters/conditions/attack"] = false
	elif state == State.ATK:
		anim_tree["parameters/conditions/attack"] = true
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/move"] = false
	elif state == State.DEAD:
		anim_tree["parameters/conditions/death"] = true

func _on_visible_on_screen_notifier_3d_screen_entered():
	set_visuals(true)

func _on_visible_on_screen_notifier_3d_screen_exited():
	set_visuals(false)
