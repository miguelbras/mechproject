extends Node

class_name Util

### miscelaneous ###

static func truncate_vector(vector, max_l):
	return vector * min(max_l / vector.length(), 1.0)

static func look_at_target(obj: Node3D, target_pos: Vector3):
	# https://ask.godotengine.org/118289/look_at-in-3d-how-to-fix-rotation-on-y-axis
	obj.rotation = Vector3.UP * lerp_angle(obj.rotation.y, atan2(target_pos.x - obj.position.x, target_pos.z - obj.position.z), 1);
