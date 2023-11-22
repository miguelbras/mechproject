extends Area3D

@export var dmg = 4

func _on_area_entered(area):
	if area.is_in_group("Mob"):
		if is_instance_valid(area.mob):
			area.mob.take_damage(dmg)
