extends Node3D

@onready var anim_tree = $AnimationTree

func _ready():
	anim_tree.active = true

func _process(delta):
	pass
