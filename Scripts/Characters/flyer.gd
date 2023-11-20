extends Mob

@export var attack1_prefab : PackedScene

@onready var anim_tree = $AnimationTree
@onready var fire_point = $"flyer/RootNode/Flyer Boi armature/Skeleton3D/Fire Point"
@onready var fire_timer = $Timer

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
	elif state == State.DEAD:
		anim_tree["parameters/conditions/death"] = true
	#elif state == State.ATK2:
	#	anim_tree["parameters/conditions/attack2"] = true

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
	var projectile = attack1_prefab.instantiate()
	fire_point.add_child(projectile)
	projectile.look_at(enemy_target.global_position)
	projectile.scale = Vector3.ONE

func _on_animation_tree_animation_started(anim_name):
	if anim_name == "Flyer Boi armature|Attack 1" and fire_timer.is_stopped():
		fire_timer.start()

func _on_timer_timeout():
	attack()
	fire_timer.stop()
