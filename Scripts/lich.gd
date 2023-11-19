extends CharacterBody3D

@onready var navigationAgent : NavigationAgent3D = $NavigationAgent3D
@onready var camera: Camera3D = get_tree().get_nodes_in_group("Camera")[0]
@onready var camera_delta: Vector3 = camera.position - self.position
@onready var projectile_spawner : Node3D = $ProjectileSpawner
@export var attack1_prefab : PackedScene
@export var Speed = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(navigationAgent.is_navigation_finished()):
		return
	
	moveToPoint(delta, Speed)
	camera.position = self.position + camera_delta

func moveToPoint(delta, speed):
	var targetPos = navigationAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	faceDirection(targetPos)
	velocity = direction * speed
	move_and_slide()

func faceDirection(direction):
	look_at(Vector3(direction.x, global_position.y, direction.z), Vector3.UP)

func _input(event):
	if Input.is_action_just_pressed("mouse_move"):
		mouse_move()
	elif Input.is_action_pressed("attack1"):
		attack1()
	elif Input.is_action_pressed("attack2"):
		pass
	elif Input.is_action_pressed("attack3"):
		pass
	elif Input.is_action_pressed("zombie_move_agg"):
		pass
	elif Input.is_action_pressed("zombie_move_pass"):
		pass

func get_mouse_target_pos():
	var mousePos = get_viewport().get_mouse_position()
	var rayLength = 100
	var from = camera.project_ray_origin(mousePos)
	var to = from + camera.project_ray_normal(mousePos) * rayLength
	var space = get_world_3d().direct_space_state
	var rayQuery = PhysicsRayQueryParameters3D.new()
	rayQuery.from = from
	rayQuery.to = to
	rayQuery.collide_with_areas = true
	var result: Dictionary = space.intersect_ray(rayQuery)
	return result

func mouse_move():
	var result = get_mouse_target_pos()
	if not result:
		return
	navigationAgent.target_position = result.position
	

func attack1():
	var projectile = attack1_prefab.instantiate()
	var result = get_mouse_target_pos()
	if not result:
		return
	faceDirection(result.position)
	projectile.rotation_degrees = projectile_spawner.global_transform.basis.get_euler()
	projectile_spawner.add_child(projectile)
