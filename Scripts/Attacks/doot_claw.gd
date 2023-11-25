extends Area3D

@export var dmg = 2

func _on_area_entered(area):
	if area.is_in_group("Enemy") and not area.is_in_group("Paladin"):
		if is_instance_valid(area.mob):
			area.mob.take_damage(dmg)
