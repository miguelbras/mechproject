extends Area3D

@export var dmg = 2

func _on_area_entered(area):
	if area.is_in_group("Enemy"):
		area.mob.take_damage(dmg)
