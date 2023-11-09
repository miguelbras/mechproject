extends CharacterBody3D

signal removed

@onready var animation_tree : AnimationTree = $AnimationTree

var minimap_icon = "mob"

func _ready():
	animation_tree.active = true

func _process(delta):
	update_animation_parameters()
	#if x
	#	 emit_signal("removed", self)
	
func update_animation_parameters():
	pass
		
