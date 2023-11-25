extends Node

@export var aggro_range: float
var closest_target: Node3D = null # target to run from
var aggro_range_squared: float
@export var parentNode: Node3D
@export var search_for_allies: bool = true
@export var searchLich = true
var target_map
#var mutex

func _ready():
	aggro_range_squared = aggro_range * aggro_range
	if search_for_allies:
		target_map = Global.arena.ally_map
		#mutex = Global.arena.ally_mutex
	else:
		target_map = Global.arena.enemy_map
		#mutex = Global.arena.enemy_mutex

func get_targets(pos: Vector3):
	var targets = []
	#mutex.lock()
	# print(Global.arena.ally_map, " ", Global.arena.ally_map.values(), " ")
	for target in target_map.values():
		if (target.position-pos).length_squared() < aggro_range_squared:
			if target is Lich and not searchLich:
				continue
			targets.append(target)
	#mutex.unlock()
	return targets

func get_closest_target(curr_target: Node3D, pos: Vector3) -> Node3D:
	var neighbours = get_targets(pos)
	print("neighbors ", neighbours)
	if len(neighbours) == 0:
		return null
	elif curr_target not in neighbours:
		var distance = (pos - neighbours[0].position).length_squared()
		for t in neighbours:
			var target_distance = (pos - t.position).length_squared()
			if target_distance < distance:
				curr_target = t
				distance = target_distance
	return curr_target

func _process(delta):
	if not is_instance_valid(closest_target):
		closest_target = null
	closest_target = get_closest_target(closest_target, parentNode.position)
	print("_process", closest_target)

