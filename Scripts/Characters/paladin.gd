extends Knight

# if lich visible follow lich and attack lich, if not follow closest mob
func follow_enemy():
	# prioritize lich
	var lich_node = Global.arena.ally_map[Global.arena.LICH_ID]
	if is_instance_valid(lich_node) and (self.position - lich_node.position).length_squared() < AggroTargetScript.aggro_range_squared:
		mob_target = lich_node
	# find other enemies if lich isn't in range
	if mob_target == null:
		mob_target = AggroTargetScript.closest_target
	# return if no enemies nearby
	if mob_target == null:
		velocity = Vector3.ZERO
		return
	# return if enemy already within attack range
	var dist = (self.position - mob_target.position).length_squared()
	var mob_in_range: bool = dist < attack_range_squared
	if not mob_in_range and mob_target is Lich:
		var closest_mob = AggroTargetScript.closest_target # fetch non lich
		if closest_mob != null:
			var dist2 = (self.position - closest_mob.position).length_squared()
			if dist2 < dist:
				mob_target = closest_mob
				mob_in_range = (self.position - mob_target.position).length_squared() < attack_range_squared
	if mob_in_range:
		velocity = Vector3.ZERO
		if can_attack:
			attack()
		return
	# chase enemy
	var desired_velocity = (mob_target.position - position) * max_velocity
	var steering = desired_velocity - velocity
	velocity = Util.truncate_vector(velocity + steering, max_velocity)
	velocity.y = 0