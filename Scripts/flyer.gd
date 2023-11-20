extends Mob

@export var attack1_prefab : PackedScene

@onready var anim_tree = $AnimationTree

func _ready():
	stop_dist = 4

func update_animation_parameters():
	if state == State.IDLE:
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/glide"] = false
	elif state == State.WALK:
		anim_tree["parameters/conditions/idle"] = false
		anim_tree["parameters/conditions/glide"] = true
	elif state == State.ATK:
		anim_tree["parameters/conditions/attack1"] = true
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/glide"] = false
	#elif state == State.ATK2:
	#	anim_tree["parameters/conditions/attack2"] = true

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "Flyer Boi armature|Attack 1" or anim_name == "Flyer Boi armature|Attack 2":
		anim_tree["parameters/conditions/attack1"] = false
		anim_tree["parameters/conditions/attack2"] = false
		attacking = false
