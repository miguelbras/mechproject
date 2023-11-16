extends CharacterBody3D

@export var max_velocity = 2
@export var hp = 10

@onready var detection_area = $ShapeCast3D
@onready var doot = load("res://Prefabs/doot.tscn")

var target = null

func truncate(vector, max):
	return vector * min(max / vector.length(), 1.0)

func get_all_targets():
	return detection_area.collision_result.map(func(x): return x.collider).filter(func(x): return x.is_in_group("mob"))

func set_current_target():
	var targets = get_all_targets()
	if len(targets) == 0:
		target = null
	elif target not in targets:
		var distance = 15
		for t in targets:
			var target_distance = (position - t.position).length()
			if target_distance <= distance:
				target = t
				distance = target_distance

func run_from_target():
	set_current_target()
	if target != null:
		var desired_velocity = (position - target.position) * max_velocity
		var steering = desired_velocity - velocity
		velocity = truncate(velocity + steering, max_velocity)
		velocity.y = 0
	else:
		velocity = Vector3.ZERO

func _physics_process(delta):
	run_from_target()
	move_and_slide()

func _on_timer_timeout():
	queue_free()

func _on_tree_exited():
	var doot_instance = doot.instantiate()
	doot_instance.position = position
	Global.arena.add_child(doot_instance)
