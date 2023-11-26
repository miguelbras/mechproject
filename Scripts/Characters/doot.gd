extends Mob

class_name Doot

@onready var anim_tree = $AnimationTree
@onready var audio_player = $AudioStreamPlayer3D
@onready var mesh = $doot

const sound1 = preload("res://Sound/Character/female-horror-voice-creature-2-attack-vol-001-138132.mp3")
const sound2 = preload("res://Sound/Character/female-horror-voice-possessed-vol-001-142646.mp3")
const sound3 = preload("res://Sound/Character/female-horror-voice-possessed-vol-002-142639.mp3")

func update_animation_parameters():
	if state == State.IDLE:
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/moving"] = false
		anim_tree["parameters/conditions/attack1"] = false
		anim_tree["parameters/conditions/attack2"] = false
	elif state == State.WALK:
		anim_tree["parameters/conditions/idle"] = false
		anim_tree["parameters/conditions/moving"] = true
		anim_tree["parameters/conditions/attack1"] = false
		anim_tree["parameters/conditions/attack2"] = false
	elif state == State.ATK:
		if atk_pattern == 0:
			anim_tree["parameters/conditions/attack1"] = true
		else:
			anim_tree["parameters/conditions/attack2"] = true
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/moving"] = false
	elif state == State.DEAD:
		anim_tree["parameters/conditions/death"] = true

func _on_death():
	audio_player.stream = sound2
	audio_player.play()

func _on_attack_timer():
	audio_player.stream = sound3
	audio_player.play()

func _on_visible_on_screen_notifier_3d_screen_entered():
	super._on_visible_on_screen_notifier_3d_screen_entered()
	mesh.set_process(true)
	anim_tree.active = true

func _on_visible_on_screen_notifier_3d_screen_exited():
	super._on_visible_on_screen_notifier_3d_screen_exited()
	mesh.set_process(false)
	anim_tree.active = false

