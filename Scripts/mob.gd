extends CharacterBody3D

class_name Mob

enum State {IDLE, WALK, ATK1, ATK2, DEAD}

signal removed

@export var max_velocity = 3

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var cast = $ShapeCast3D

# var minimap_icon = "mob"
var target_velocity = Vector3.ZERO
var target = null
var stop_dist = 2
var state = State.IDLE
var attacking = false

func _ready():
	animation_tree.active = true

func _process(delta):
	update_state()
	update_animation_parameters()

func _physics_process(delta):
	if not attacking:
		follow_target()
	else:
		attack_target()
	look_at_target(delta)
	move_and_slide()

func follow_target():
	target = Util.get_closest_target(target, position, cast, "civ")
	if target != null and target.position.distance_to(position) > stop_dist:
		var desired_velocity = (target.position - position) * max_velocity
		var steering = desired_velocity - velocity
		velocity = Util.truncate_vector(velocity + steering, max_velocity)
		velocity.y = 0
	else:
		velocity = Vector3.ZERO

func look_at_target(delta):
	if target != null:
		look_at(target.position, Vector3.UP, true)

func attack_target():
	pass

func update_state():
		if velocity == Vector3.ZERO and target == null:
			state = State.IDLE
		elif velocity == Vector3.ZERO and target != null:
			if not attacking:
				state = State.ATK1 if randf() > 0.5 else State.ATK2
				attacking = true
		else:
			state = State.WALK

func update_animation_parameters():
	pass
