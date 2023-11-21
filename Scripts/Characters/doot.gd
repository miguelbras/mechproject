extends Mob

@onready var anim_tree = $AnimationTree

func update_animation_parameters():
	if state == State.IDLE:
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/moving"] = false
	elif state == State.WALK:
		anim_tree["parameters/conditions/idle"] = false
		anim_tree["parameters/conditions/moving"] = true
	elif state == State.ATK:
		if atk_pattern == 0:
			anim_tree["parameters/conditions/attack1"] = true
		else:
			anim_tree["parameters/conditions/attack2"] = true
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/moving"] = false
	elif state == State.DEAD:
		anim_tree["parameters/conditions/death"] = true

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "Doot Boi armature_001|Death":
		queue_free()
	elif anim_name == "Doot Boi armature_001|Attack" or anim_name == "Doot Boi armature_001|Attack02":
		anim_tree["parameters/conditions/attack1"] = false
		anim_tree["parameters/conditions/attack2"] = false
		attacking = false
