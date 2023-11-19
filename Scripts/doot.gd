extends Mob

@onready var anim_tree = $AnimationTree
@onready var timer = $Timer

var prev_state = State.IDLE
var virt_state = State.IDLE

func update_animation_parameters():
	
	if state == State.WALK:
		virt_state = state
		if not timer.is_stopped():
			timer.stop()
	if prev_state == State.WALK and state == State.IDLE and timer.is_stopped():
		timer.start()
	
	if virt_state == State.IDLE:
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/moving"] = false
	elif virt_state == State.WALK:
		anim_tree["parameters/conditions/idle"] = false
		anim_tree["parameters/conditions/moving"] = true
	elif virt_state == State.ATK1:
		anim_tree["parameters/conditions/attack1"] = true
	elif virt_state == State.ATK2:
		anim_tree["parameters/conditions/attack2"] = true

	prev_state = state


func _on_timer_timeout():
	virt_state = state
	timer.stop()


func _on_animation_tree_animation_finished(anim_name):
	print(anim_name)
	if anim_name == "":
		anim_tree["parameters/conditions/attack1"] = false
		attacking = false
	elif anim_name == "":
		anim_tree["parameters/conditions/attack2"] = false
		attacking = false
