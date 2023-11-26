extends CharacterBody3D

class_name Mob

enum State {IDLE, WALK, ATK, DEAD}

@export var hp = 10
@export var defense = 0
@export var strength = 2
@export var max_velocity = 3

@onready var AggroTargetScript = $Thread1Node
@onready var attack_range = $AttackRange
@onready var move_target = position # position to move on command
@onready var death_timer: Timer = $DeathTimer
@onready var cooldown = $Cooldown

var target_velocity = Vector3.ZERO # direction to move
var state = State.IDLE # animation state
var attacking = false # is attacking (so it doesnt move while attack animation is running)
var can_attack = true # cooldown so it does not endlessly attack
var enemy_target # target to follow and attack
var atk_pattern = 0 # select which attack to use next
var aggressive: bool = true # if aggressive should attack player, if not just move to command target and wait
var last_positions = [] # check if is blocked, if so put it IDLE
var last_positions_amount = 20 # idem
var lich
var follower: bool = false
var my_id
var process_tick_curr = 0
var process_tick_max = 10

func _ready():
	set_as_top_level(true)
	await Engine.get_main_loop().physics_frame
	move_target = self.position
	my_id = Global.arena.ally_spawned_light(self)

func _on_tree_exited():
	Global.arena.ally_despawned_light(my_id)

func _physics_process(_delta):
	if not attacking:
		if aggressive:
			follow_enemy()
		# if no enemy nearby, or if passive, just move to destination
		if enemy_target == null or not aggressive:
			if follower:
				move_target = lich.position
			follow_target()
		check_blocked()
	update_state()
	update_animation_parameters()
	look_at_target()
	move_and_slide()
	
func check_blocked():
	# return if not trying to move
	if velocity == Vector3.ZERO:
		return
	# sample
	last_positions.append(position)
	# return if we dont have enough samples
	if len(last_positions) < last_positions_amount:
		return
	# remove oldest sample
	while len(last_positions) > last_positions_amount:
		last_positions.remove_at(0)
	# check if we've been in the same place for a while
	var blocked = true
	for i in range(last_positions_amount):
		if (last_positions[0] - last_positions[i]).length() > 0.1:
			blocked = false
	if blocked:
		move_target = position

func follow_enemy():
	enemy_target = AggroTargetScript.closest_target
	# return if enemy not found
	if enemy_target == null:
		velocity = Vector3.ZERO
		return
	# return if enemy already within attack range
	# TODO have buildings with detection area instead?
	var enemy_in_range: bool = enemy_target in Util.get_all_targets(attack_range, "Enemy")
	if enemy_in_range:
		velocity = Vector3.ZERO
		if can_attack:
			attack()
		return
	# chase enemy
	var desired_velocity = (enemy_target.position - position) * max_velocity
	var steering = desired_velocity - velocity
	velocity = Util.truncate_vector(velocity + steering, max_velocity)
	velocity.y = 0

func follow_target():
	var distance_to_target: Vector3 = move_target - self.position
	# dont move if right next to target
	var threshold = 0.1 if not follower else 3.0
	if distance_to_target.length_squared() < threshold:
		velocity = Vector3.ZERO
		return
	var desired_velocity = distance_to_target * max_velocity
	var steering = desired_velocity - velocity
	velocity = Util.truncate_vector(velocity + steering, max_velocity)
	velocity.y = 0

func look_at_target():
	if aggressive and enemy_target != null:
		Util.look_at_target(self, enemy_target.position)
		return
	# only look if target is far away
	if (move_target - position).length() > 0.15:
		Util.look_at_target(self, move_target)

func update_state():
	if hp <= 0:
		state = State.DEAD
	elif velocity != Vector3.ZERO:
		state = State.WALK
	elif velocity == Vector3.ZERO:
		if enemy_target != null:
			if attacking:
				state = State.ATK
			else:
				state = State.IDLE
		else:
			state = State.IDLE

func update_animation_parameters():
	pass
	
func aggressive_move(target_position: Vector3):
	aggressive = true
	follower = false
	move_target = target_position
	last_positions.clear()
	
func passive_move(target_position: Vector3):
	aggressive = false
	follower = false
	move_target = target_position
	last_positions.clear()
	
func follow_mode(lich: Lich):
	aggressive = false
	follower = true
	self.lich = lich
	move_target = lich.position#target_position
	last_positions.clear()

func take_damage(damage: int):
	damage -= defense
	if damage > 0:
		hp -= damage
	if hp <= 0 and death_timer.is_stopped():
		death_timer.start()
		_on_death()

func _on_visible_on_screen_notifier_3d_screen_entered():
	if self not in Global.arena.visible_mobs:
		Global.arena.visible_mobs += [self]

func _on_visible_on_screen_notifier_3d_screen_exited():
	if self in Global.arena.visible_mobs:
		Global.arena.visible_mobs.erase(self)

func _on_death_timer_timeout():
	queue_free()

func _on_cooldown_timeout():
	can_attack = true
	attacking = false

func _on_death():
	pass

func attack():
	atk_pattern = 0 if randf() > 0.5 else 1
	cooldown.start()
	_on_attack_timer()
	enemy_target.take_damage(strength)
	can_attack = false
	attacking = true

func _on_attack_timer():
	pass

