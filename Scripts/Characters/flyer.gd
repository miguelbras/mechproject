extends Mob

@export var attack1_prefab : PackedScene

@onready var anim_tree = $AnimationTree
@onready var fire_point = $"flyer/RootNode/Flyer Boi armature/Skeleton3D/Fire Point"
@onready var fire_timer = $Timer
@onready var audio_player = $AudioStreamPlayer3D

const sound1 = preload("res://Sound/Character/dragon-roar-96996.mp3")
const sound2 = preload("res://Sound/Attack/fire-magic-6947.mp3")

var fire_pattern = 0 # remember which attack was selected

func _ready():
	super._ready()
	audio_player.stream = sound1
	audio_player.play()

func update_animation_parameters():
	if state == State.IDLE:
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/glide"] = false
	elif state == State.WALK:
		anim_tree["parameters/conditions/idle"] = false
		anim_tree["parameters/conditions/glide"] = true
	elif state == State.ATK:
		if atk_pattern == 0:
			anim_tree["parameters/conditions/attack1"] = true
		else:
			anim_tree["parameters/conditions/attack2"] = true
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/glide"] = false
	elif state == State.DEAD:
		anim_tree["parameters/conditions/death"] = true

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "Flyer Boi armature|Death Fall":
		queue_free()
	if anim_name == "Flyer Boi armature|Attack 1" or anim_name == "Flyer Boi armature|Attack 2":
		anim_tree["parameters/conditions/attack1"] = false
		anim_tree["parameters/conditions/attack2"] = false
		attacking = false

func attack():
	if enemy_target == null:
		return
	audio_player.stream = sound2
	audio_player.play()
	if fire_pattern == 0:
		var projectile = attack1_prefab.instantiate()
		fire_point.add_child(projectile)
		projectile.look_at(enemy_target.global_position)
		projectile.scale = Vector3.ONE
	else:
		for angle in [-60, -30, 0, 30, 60]:
			var projectile = attack1_prefab.instantiate()
			fire_point.add_child(projectile)
			projectile.look_at(enemy_target.global_position)
			projectile.rotate_y(deg_to_rad(angle))
			projectile.scale = Vector3.ONE

func _on_animation_tree_animation_started(anim_name):
	if fire_timer.is_stopped():
		if anim_name == "Flyer Boi armature|Attack 1":
			fire_timer.start(0.9)
			fire_pattern = 0
		elif anim_name == "Flyer Boi armature|Attack 2":
			fire_timer.start(1.4)
			fire_pattern = 1

func _on_timer_timeout():
	attack()
	fire_timer.stop()
