extends Area3D

@export var dmg = 1
@export var spd = 15

var dir = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position -= transform.basis.z * spd * delta

func _on_dmg(body: Node) -> void:
	if not body.is_in_group("Enemy"):
		return
	body.take_damage(dmg)
	# spawn explosion
	if not body.is_in_group("Building"):
		body.set_dot()
	queue_free()
	

func _on_timeout() -> void:
	queue_free()