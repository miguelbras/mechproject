extends StaticBody3D

@onready var mesh = $mesh

func set_visuals(enable: bool):
	mesh.set_process(enable)
	mesh.visible = enable

func _ready():
	set_visuals(false)

func _on_visible_on_screen_notifier_3d_screen_entered():
	set_visuals(true)

func _on_visible_on_screen_notifier_3d_screen_exited():
	set_visuals(false)
