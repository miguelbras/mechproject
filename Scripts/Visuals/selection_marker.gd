extends Node3D

@onready var anim_tree = $AnimationTree
var base

func _ready():
	anim_tree.active = true
	base = global_transform.basis

func _process(delta):
	global_transform.basis = base
