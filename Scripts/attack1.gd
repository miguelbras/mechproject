extends Area3D

var dir = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position -= transform.basis.x * 150 * delta

func _on_dmg(body: Node) -> void:
	if body.in_in_group("Enemy"):
		body.take_damage(1)
	queue_free()

func _on_timeout() -> void:
	queue_free()
