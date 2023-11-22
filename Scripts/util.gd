extends Node

class_name Util

### miscelaneous ###

static func truncate_vector(vector, max):
	return vector * min(max / vector.length(), 1.0)

static func look_at_target(obj: Node3D, target_pos: Vector3):
	# https://ask.godotengine.org/118289/look_at-in-3d-how-to-fix-rotation-on-y-axis
	obj.rotation = Vector3.UP * lerp_angle(obj.rotation.y, atan2(target_pos.x - obj.position.x, target_pos.z - obj.position.z), 1);

### behaviour ###

static func get_all_targets(cast: ShapeCast3D, group: String):
	return cast.collision_result.map(func(x): return x.collider).filter(func(x): return x and x.is_in_group(group))

static func get_closest_target(curr_target, pos: Vector3, cast: ShapeCast3D, group: String):
	var neighbours = get_all_targets(cast, group)
	if len(neighbours) == 0:
		return null
	elif curr_target not in neighbours:
		var distance = 1500
		for t in neighbours:
			var target_distance = (pos - t.position).length()
			if target_distance <= distance:
				curr_target = t
				distance = target_distance
	return curr_target
