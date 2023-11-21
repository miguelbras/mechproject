extends Area3D

@export var dmg = 3

func _on_area_entered(area):
	if area.is_in_group("Mob"):
		area.mob.take_damage(dmg)
