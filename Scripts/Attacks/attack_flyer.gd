extends RangedAttack

func _on_dmg(body: Node) -> void:
	if not body.is_in_group("Enemy") or not body.has_method("take_damage"):
		return
	body.take_damage(strength)
	# spawn explosion
	if not body.is_in_group("Building"):
		body.set_dot()
	queue_free()
	

func _on_timeout() -> void:
	queue_free()
