extends CharacterBody3D

class_name Mob

enum State {IDLE, WALK, ATK, DEAD}

signal removed

@export var hp = 10
@export var max_velocity = 3

@onready var cast = $ShapeCast3D

# var minimap_icon = "mob"
var target_velocity = Vector3.ZERO

var stop_dist = 2
var state = State.IDLE
var attacking = false
var enemy_target = null
var move_target = null
var aggressive: bool = true

func _physics_process(delta):
	if not attacking:
		if aggressive:
			follow_enemy()
		# if no enemy nearby, or if passive, just move to destination
		elif enemy_target == null:
			follow_target()
	update_state()
	update_animation_parameters()
	look_at_target()
	move_and_slide()

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
	if move_target != null:
		var desired_velocity = (move_target - position) * max_velocity
		var steering = desired_velocity - velocity
		velocity = Util.truncate_vector(velocity + steering, max_velocity)
		velocity.y = 0
	else:
		velocity = Vector3.ZERO

func look_at_target():
	if aggressive and enemy_target != null:
		self.look_at(enemy_target.position, Vector3.UP, true)
	elif move_target != null:
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
	
func passive_move(position: Vector3):
	aggressive = false
	move_target = position

func take_damage(dmg: int):
	hp -= dmg
