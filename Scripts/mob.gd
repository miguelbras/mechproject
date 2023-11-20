extends CharacterBody3D

class_name Mob

enum State {IDLE, WALK, ATK, DEAD}

signal removed

@export var max_velocity = 3

#@onready var animation_tree : AnimationTree = $AnimationTree
@onready var cast = $ShapeCast3D

# var minimap_icon = "mob"
var target_velocity = Vector3.ZERO
var target = null
var stop_dist = 2
var state = State.IDLE
var attacking = false

#func _ready():
#	animation_tree.active = true

func _process(delta):
	update_state()
	update_animation_parameters()

func _physics_process(delta):
	if not attacking:
		follow_target()
	look_at_target(delta)
	move_and_slide()

func follow_target():
	target = Util.get_closest_target(target, position, cast, "Enemy")
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

func update_state():
	if not attacking:
		if velocity == Vector3.ZERO:
			if target == null:
				state = State.IDLE
			else:
				state = State.ATK
				attacking = true
		else:
			state = State.WALK
	#else:
	#	if target.velocity != Vector3.ZERO:
	#		attacking = false

func update_animation_parameters():
	pass
