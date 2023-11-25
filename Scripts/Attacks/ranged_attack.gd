extends Area3D

class_name RangedAttack

@export var strength = 1
@export var speed = 15

var dir = Vector3()

func _ready():
	set_as_top_level(true)

func _process(delta):
	self.position -= transform.basis.z * speed * delta
