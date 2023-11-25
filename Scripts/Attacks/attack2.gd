extends RangedAttack

func _on_dmg(body: Node) -> void:
	if body.is_in_group("Building"):
		queue_free()
	elif body.is_in_group("Enemy"):
		body.take_damage(strength)
		# spawn explosion
		body.set_dot()
		queue_free()

func _on_timeout() -> void:
	queue_free()
