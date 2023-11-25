extends Mob

class_name Doot

@onready var anim_tree = $AnimationTree
@onready var audio_player = $AudioStreamPlayer3D

const sound1 = preload("res://Sound/Character/female-horror-voice-creature-2-attack-vol-001-138132.mp3")
const sound2 = preload("res://Sound/Character/female-horror-voice-possessed-vol-001-142646.mp3")
const sound3 = preload("res://Sound/Character/female-horror-voice-possessed-vol-002-142639.mp3")

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

func _on_animation_tree_animation_started(anim_name):
	if anim_name == "Doot Boi armature_001|Death":
		audio_player.stream = sound2
		audio_player.play()
	if anim_name == "Doot Boi armature_001|Attack" or anim_name == "Doot Boi armature_001|Attack02":
		audio_player.stream = sound3
		audio_player.play()

func _on_ready():
	my_id = Global.arena.ally_spawned(self)
	super._ready()
	audio_player.stream = sound1
	audio_player.play()

func _on_tree_exited():
	Global.arena.ally_despawned(my_id)
