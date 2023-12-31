extends Node

@export var aggro_range: float
var closest_target
var neighbours = []
var aggro_range_squared: float
@export var parentNode: Node3D
@export var search_for_allies: bool = true
@export var searchLich = true
var target_map

func _ready():
	aggro_range_squared = aggro_range * aggro_range
	if search_for_allies:
		target_map = Global.arena.ally_map
	else:
		target_map = Global.arena.enemy_map

func get_targets(pos: Vector3):
	var targets = []
	# print(Global.arena.ally_map, " ", Global.arena.ally_map.values(), " ")
	for target in target_map.values():
		if (target.position-pos).length_squared() < aggro_range_squared:
			if target is Lich and not searchLich:
				continue
			targets.append(target)
	return targets

func get_closest_target(curr_target: Node3D, pos: Vector3) -> Node3D:
	neighbours = get_targets(pos)
	if len(neighbours) == 0:
		return null
	elif curr_target not in neighbours:
		var distance = (pos - neighbours[0].position).length_squared()
		curr_target = neighbours[0]
		for t in neighbours:
			var target_distance = (pos - t.position).length_squared()
			if target_distance < distance:
				curr_target = t
				distance = target_distance
	return curr_target

func _process(_delta):
	if not is_instance_valid(null): # if we want them to keep following same target, use closest_target instead
		closest_target = null
	closest_target = get_closest_target(closest_target, parentNode.position)

