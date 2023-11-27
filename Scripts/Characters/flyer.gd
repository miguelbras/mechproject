extends Mob

@export var attack_prefab : PackedScene

@onready var anim_tree = $AnimationTree
@onready var fire_point = $"flyer/RootNode/Flyer Boi armature/Skeleton3D/Fire Point"
@onready var fire_timer = $Timer
@onready var audio_player = $AudioStreamPlayer3D
@onready var fbx = $flyer

const sound1 = preload("res://Sound/Character/dragon-roar-96996.mp3")
const sound2 = preload("res://Sound/Attack/fire-magic-6947.mp3")

var fire_pattern = 0 # remember which attack was selected

func _on_ready():
	audio_player.stream = sound1
	audio_player.play()
	set_visuals(false)

func set_visuals(enable: bool):
	fbx.set_process(enable)
	fbx.visible = enable
	anim_tree.active = enable

func update_animation_parameters():
	if state == State.IDLE:
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/glide"] = false
		anim_tree["parameters/conditions/attack1"] = false
		anim_tree["parameters/conditions/attack2"] = false
	elif state == State.WALK:
		anim_tree["parameters/conditions/idle"] = false
		anim_tree["parameters/conditions/glide"] = true
		anim_tree["parameters/conditions/attack1"] = false
		anim_tree["parameters/conditions/attack2"] = false
	elif state == State.ATK:
		if atk_pattern == 0:
			anim_tree["parameters/conditions/attack1"] = true
		else:
			anim_tree["parameters/conditions/attack2"] = true
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/glide"] = false
	elif state == State.DEAD:
		anim_tree["parameters/conditions/death"] = true

func attack():
	atk_pattern = 0 if randf() > 0.5 else 1
	cooldown.start()
	_on_attack_timer()
	can_attack = false
	attacking = true

func fire():
	if enemy_target == null:
		return
	audio_player.stream = sound2
	audio_player.play()
	if fire_pattern == 0:
		var projectile = attack_prefab.instantiate()
		fire_point.add_child(projectile)
		projectile.look_at(enemy_target.global_position)
		projectile.scale = Vector3.ONE
	else:
		for angle in [-60, -30, 0, 30, 60]:
			var projectile = attack_prefab.instantiate()
			fire_point.add_child(projectile)
			projectile.look_at(enemy_target.global_position)
			projectile.rotate_y(deg_to_rad(angle))
			projectile.scale = Vector3.ONE

func _on_timer_timeout():
	fire()
	fire_timer.stop()

func _on_attack_timer():
	if atk_pattern == 0:
		fire_timer.start(0.9)
		fire_pattern = 0
	else:
		fire_timer.start(1.4)
		fire_pattern = 1

func _on_visible_on_screen_notifier_3d_screen_entered():
	set_visuals(true)

func _on_visible_on_screen_notifier_3d_screen_exited():
	set_visuals(false)

func _on_tree_exited_child():
	super._on_tree_exited()
