extends CharacterBody3D

class_name Mob

enum MobState {IDLE, MOVE, ATK1, ATK2, DEAD, N}

signal removed

@export var hp = 10
@export var atk1_power = 3
@export var atk2_power = 5
@export var max_velocity = 3

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var cast = $ShapeCast3D

var state : MobState
var minimap_icon = "mob"
var target_velocity = Vector3.ZERO

var target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree.active = true
	state = MobState.IDLE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#var pState = state
	# var target = set_target()
	#return
	#state = next_behabiour()
	#if state != pState:
	#	switch_behaviour()
	update_animation_parameters()

func _physics_process(delta):
	follow_target()
	move_and_slide()

func follow_target():
	target = Util.get_closest_target(target, position, cast, "civ")
	if target != null:
		var desired_velocity = (target.position - position) * max_velocity
		var steering = desired_velocity - velocity
		velocity = Util.truncate_vector(velocity + steering, max_velocity)
		velocity.y = 0
	else:
		velocity = Vector3.ZERO


func next_behabiour():
	pass

func switch_behaviour():
	pass

func perform_behaviour():
	pass

func update_animation_parameters():
	pass
