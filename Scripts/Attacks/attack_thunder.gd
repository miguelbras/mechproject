extends Area3D

@export var strength = 5

@onready var flip_timer = $FlipTimer
@onready var collision = $CollisionShape3D
@onready var sprite = $Sprite3D

func _on_dmg(body: Node) -> void:
	if is_instance_valid(collision):
		if body.is_in_group("Building"):
			collision.queue_free()
		elif body is Knight or body is Paladin:
			body.take_damage(strength - 2)
		elif body.is_in_group("Enemy"):
			body.take_damage(strength)
			collision.queue_free()

func _on_timeout() -> void:
	queue_free()

func _on_flip_timer_timeout():
	sprite.rotation_degrees.x = 90
	sprite.rotation_degrees.y = 90
	sprite.rotation_degrees.z = -90
