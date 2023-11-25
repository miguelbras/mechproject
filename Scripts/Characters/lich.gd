extends CharacterBody3D

class_name Lich
signal healthChanged
signal abilityUsed
signal coolDownThick(deltaTime)

@export var attack1_prefab : PackedScene
@export var attack2_prefab : PackedScene
@export var attack3_prefab : PackedScene
@export var selection_node : Area3D
@export var camera: Camera3D
@export var my_speed = 6
@export var attack_cooldown_ms = 1000
@export var maxHp = 30
@export var hp = maxHp

@onready var navigationAgent : NavigationAgent3D = $NavigationAgent3D
@onready var camera_delta: Vector3 = camera.position - position
@onready var projectile_spawner : Node3D = $ProjectileSpawner
@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer

const atk1_sound = preload("res://Sound/Attack/Eldritch Blast.wav")
const atk2_sound = preload("res://Sound/Attack/fire-magic-6947.mp3")
const atk3_sound = preload("res://Sound/Attack/magic-spell-6005.mp3")

var last_time_attacked = 0
var selected = []
var followers = []

func _process(delta):
	coolDownThick.emit(delta)
	if(navigationAgent.is_navigation_finished()):
		return
	moveToPoint(delta, my_speed)
	camera.position = position + camera_delta

func moveToPoint(_delta, speed):
	var targetPos = navigationAgent.get_next_path_position()
	var direction = global_position.direction_to(targetPos)
	faceDirection(targetPos)
	velocity = direction * speed
	move_and_slide()

func faceDirection(direction):
	Util.look_at_target(self, Vector3(direction.x, global_position.y, direction.z))

func _input(event):
	if Global.arena.game_over:
		return
	if Input.is_action_pressed("zombie_move_agg"):
		zombies_agg()
	elif Input.is_action_pressed("zombie_move_pass"):
		zombies_pass()
	elif Input.is_action_pressed("mouse_move"):
		mouse_move()
	elif Input.is_action_pressed("attack1"):
		attack1()
	elif Input.is_action_pressed("attack2"):
		attack2()
	elif Input.is_action_pressed("attack3"):
		attack3()
	elif not Input.is_action_pressed("test_alt"):
		selection_node.input(event)

func get_mouse_target_pos():
	var mousePos = get_viewport().get_mouse_position()
	var rayLength = 100
	var from = camera.project_ray_origin(mousePos)
	var to = from + camera.project_ray_normal(mousePos) * rayLength
	var space = get_world_3d().direct_space_state
	var rayQuery = PhysicsRayQueryParameters3D.new()
	rayQuery.from = from
	rayQuery.to = to
	rayQuery.set_collision_mask(2) # only collide with floor, on layer 2
	var result: Dictionary = space.intersect_ray(rayQuery)
	return result

func mouse_move():
	var result = get_mouse_target_pos()
	if not result:
		return
	navigationAgent.target_position = result.position

func attack(projectile):
	var result = get_mouse_target_pos()
	if not result:
		return
	faceDirection(result.position)
	projectile.rotation_degrees = projectile_spawner.global_transform.basis.get_euler()
	projectile_spawner.add_child(projectile)
	
	# stop moving, add CD to attack
	navigationAgent.target_position = position
	last_time_attacked = Time.get_ticks_msec()
	
func attack1():
	if last_time_attacked + attack_cooldown_ms > Time.get_ticks_msec():
		return
	audio_player.stream = atk1_sound
	audio_player.play()
	attack(attack1_prefab.instantiate())
	abilityUsed.emit()

func attack2():
	if last_time_attacked + attack_cooldown_ms > Time.get_ticks_msec():
		return
	audio_player.stream = atk2_sound
	audio_player.play()
	attack(attack2_prefab.instantiate())
	abilityUsed.emit()

func attack3():
	if last_time_attacked + attack_cooldown_ms > Time.get_ticks_msec():
		return
	audio_player.stream = atk3_sound
	audio_player.play()
	attack(attack3_prefab.instantiate())
	abilityUsed.emit()

func command_dispatch():
	for mob in followers:
		if is_instance_valid(mob): # mob could have died
			followers.erase(mob)
			# TODO: command old follower to hunt civilians
	
func command_follow():
	for mob in selected:
		if is_instance_valid(mob) and mob not in followers: # mob could have died
			followers += [mob]
			# TODO: command new follower to follow lich

func zombies_agg():
	var result = get_mouse_target_pos()
	if not result:
		return
	for mob in selection_node.selected_mobs:
		if is_instance_valid(mob):
			mob.aggressive_move(result.position)

func zombies_pass():
	var result = get_mouse_target_pos()
	if not result:
		return
	for mob in selection_node.selected_mobs:
		if is_instance_valid(mob):
			mob.passive_move(result.position)

func take_damage(dmg: int):
	hp -= dmg
	healthChanged.emit()
	if hp <= 0:
		Global.arena.lose()
		queue_free()
