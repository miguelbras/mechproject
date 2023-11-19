extends CharacterBody3D

class_name Mob

signal removed

@export var hp = 10
@export var atk1_power = 3
@export var atk2_power = 5
@export var max_velocity = 3

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var cast = $ShapeCast3D
@onready var mesh: MeshInstance3D

var minimap_icon = "mob"
var target_velocity = Vector3.ZERO

var target = null

func _ready():
	animation_tree.active = true

func _process(delta):
	update_animation_parameters()

func _physics_process(delta):
	follow_target()
	# look_to_target()
	move_and_slide()

func follow_target():
	target = Util.get_closest_target(target, position, cast, "civ")
	if target != null and target.position.distance_to(position) > 2:
		var desired_velocity = (target.position - position) * max_velocity
		var steering = desired_velocity - velocity
		velocity = Util.truncate_vector(velocity + steering, max_velocity)
		velocity.y = 0
	else:
		velocity = Vector3.ZERO

func look_to_target():
	if target != null:
		mesh.look_at(target.position)

func update_animation_parameters():
	pass
