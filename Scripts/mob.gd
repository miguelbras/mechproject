extends CharacterBody3D

class_name Mob

enum AIState {IDLE, MOVE, ATK1, ATK2, DEAD, N}

signal removed

@export var hp = 10
@export var atk1_power = 3
@export var atk2_power = 5

@onready var animation_tree : AnimationTree = $AnimationTree

var state : AIState
var minimap_icon = "mob"
var target_velocity = Vector3.ZERO
var targets = []

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree.active = true
	state = AIState.IDLE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var pState = state
	var target = set_target()
	return
	state = next_behabiour()
	if state != pState:
		switch_behaviour()
	update_animation_parameters()

func set_target():
	var keepTarget = true
	if state == AIState.IDLE:
		pass

func next_behabiour():
	pass

func switch_behaviour():
	pass

func perform_behaviour():
	pass

func update_animation_parameters():
	pass
