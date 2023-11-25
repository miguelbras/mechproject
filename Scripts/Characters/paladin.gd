extends Knight

# if lich visible follow lich and attack lich, if not follow closest mob
func follow_enemy():
	mob_target = Util.get_closest_target(mob_target, position, aggro_range, "Lich")
	# return if enemy not found
	if mob_target == null:
		mob_target = Util.get_closest_target(mob_target, position, aggro_range, "Mob")
		if mob_target == null:
			velocity = Vector3.ZERO
			return
	# return if enemy already within attack range
	var mob_in_range: bool = mob_target in Util.get_all_targets(attack_range, "Lich")
	if not mob_in_range:
		mob_in_range = mob_target in Util.get_all_targets(attack_range, "Mob")
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
