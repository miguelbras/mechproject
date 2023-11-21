extends CharacterBody3D

class_name Mob

enum State {IDLE, WALK, ATK, DEAD}

signal removed

@export var hp = 10
@export var max_velocity = 3

@onready var cast = $ShapeCast3D

var target_velocity = Vector3.ZERO

var stop_dist = 2
var state = State.IDLE
var attacking = false
var enemy_target = null
var atk_pattern = 0
@onready var move_target = self.position
var aggressive: bool = true

var last_positions = []
var last_positions_amount = 20

func _physics_process(delta):
	if not attacking:
		if aggressive:
			follow_enemy()
		# if no enemy nearby, or if passive, just move to destination
		if enemy_target == null or not aggressive:
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
	
	last_positions.append(self.position)
	# return if we dont have enough samples
	if len(last_positions) < last_positions_amount:
		return
	
	while len(last_positions) > last_positions_amount:
		last_positions.remove_at(0)
	
	# check if we've been in the same place for a while
	var blocked = true
	for i in range(last_positions_amount):
		if (last_positions[0] - last_positions[i]).length() > 0.1:
			blocked = false
	if blocked:
		#print("blocked")
		move_target = self.position

func follow_enemy():
	enemy_target = Util.get_closest_target(enemy_target, position, cast, "Enemy")
	if enemy_target != null and enemy_target.position.distance_to(position) > stop_dist:
		var desired_velocity = (enemy_target.position - position) * max_velocity
		var steering = desired_velocity - velocity
		velocity = Util.truncate_vector(velocity + steering, max_velocity)
		velocity.y = 0
	else:
		velocity = Vector3.ZERO

func follow_target():
	var distance_to_target: Vector3 = move_target - position
	
	# dont move if right next to target
	if distance_to_target.length_squared() < 0.1:
		velocity = Vector3.ZERO
		return
		
	var desired_velocity = distance_to_target * max_velocity
	var steering = desired_velocity - velocity
	velocity = Util.truncate_vector(velocity + steering, max_velocity)
	velocity.y = 0

func look_at_target():
	if aggressive and enemy_target != null:
		self.look_at(enemy_target.position, Vector3.UP, true)
		return
	# only look if target is far away
	if (move_target - position).length() > 0.1:
		self.look_at(move_target, Vector3.UP, true)

func update_state():
	if hp <= 0:
		state = State.DEAD
	elif velocity != Vector3.ZERO and not attacking:
		state = State.WALK
	elif velocity == Vector3.ZERO:
		if enemy_target != null and aggressive:
			state = State.ATK
			attacking = true
			atk_pattern = 0 if randf() > .35 else 1
		else:
			state = State.IDLE
	#if "Doot" in name:
	#	var dist = (enemy_target.position.distance_to(position) > stop_dist) if enemy_target != null else null
	#	print(state, " ", velocity, " ", enemy_target, " ", aggressive, " ", dist, " ", attacking)

func update_animation_parameters():
	pass
	
func aggressive_move(position: Vector3):
	aggressive = true
	move_target = position
	last_positions.clear()
	
func passive_move(position: Vector3):
	aggressive = false
	move_target = position
	last_positions.clear()

func take_damage(dmg: int):
	hp -= dmg
