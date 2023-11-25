extends Node


@export var aggro_range: float
var target: Node3D = null # target to run from
var aggro_range_squared: float
@export var parentNode: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	aggro_range_squared = aggro_range * aggro_range


func get_ally_targets(pos: Vector3):
	var allies = []
	for ally in Global.arena.ally_map.values():
		if (ally.position-pos).length_squared() < aggro_range_squared:
			allies.append(ally)
	return allies

func get_closest_target(curr_target: Node3D, pos: Vector3) -> Node3D:
	var neighbours = get_ally_targets(pos)
	if len(neighbours) == 0:
		return null
	elif curr_target not in neighbours:
		var distance = 1500
		for t in neighbours:
			var target_distance = (pos - t.position).length_squared()
			if target_distance <= distance:
				curr_target = t
				distance = target_distance
	return curr_target


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	target = get_closest_target(target, parentNode.position)
