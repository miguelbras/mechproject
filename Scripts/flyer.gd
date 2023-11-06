extends CharacterBody3D

@onready var animation_tree : AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true

func _process(delta):
	update_animation_parameters()
	
func update_animation_parameters():
	pass
