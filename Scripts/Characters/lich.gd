extends CharacterBody3D

class_name Lich

enum State {IDLE, WALK, ATK, DEAD}

signal healthChanged
signal abilityUsed
signal coolDownThick(deltaTime)

@export var attack1_prefab : PackedScene
@export var attack2_prefab : PackedScene
@export var attack3_prefab : PackedScene
#@export var selection_node : Area3D
@export var camera: Camera3D
@export var my_speed = 6
@export var attack_cooldown_ms = 1000
@export var maxHp = 30
@export var defense = 0

@onready var navigationAgent : NavigationAgent3D = $NavigationAgent3D
@onready var camera_delta: Vector3 = camera.position - position
@onready var projectile_spawner : Node3D = $ProjectileSpawner
@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer
@onready var anim_tree = $AnimationTree
@onready var death_timer = $DeathTimer
@onready var cooldown = $Cooldown
@onready var timer = $Timer

const atk1_sound = preload("res://Sound/Attack/Eldritch Blast.wav")
const atk2_sound = preload("res://Sound/Attack/fire-magic-6947.mp3")
const atk3_sound = preload("res://Sound/Attack/magic-spell-6005.mp3")
const flyer = preload("res://Prefabs/Characters/flyer.tscn")

var hp = maxHp
var last_time_attacked = 0
var followers = []
var state = State.IDLE # animation state
var atk_pattern = 0
var attacking = false

func _on_ready():
	Global.arena.lich_spawned(self)
	anim_tree.active = true

func _process(delta):
	coolDownThick.emit(delta)
	update_state()
	update_animation_parameters()
	if(navigationAgent.is_navigation_finished()):
		velocity = Vector3.ZERO
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
	#if Input.is_action_pressed("zombie_move_agg"):
	#	zombies_agg()
	elif Input.is_action_pressed("zombie_move"):
		#zombies_pass()
		if not attacking:
			atk_pattern = 3
			attacking = true
			cooldown.start()
		if len(followers) == 0:
			command_follow()
		else:
			zombies_agg()
	elif Input.is_action_pressed("mouse_move"):
		mouse_move()
	elif Input.is_action_pressed("attack1"):
		if not attacking:
			atk_pattern = 0
			attacking = true
			cooldown.start(0.5)
			timer.start()
	elif Input.is_action_pressed("attack2"):
		if not attacking:
			atk_pattern = 1
			attacking = true
			cooldown.start()
			timer.start()
	elif Input.is_action_pressed("attack3"):
		if not attacking:
			atk_pattern = 2
			attacking = true
			cooldown.start(2.3)
			timer.start()
	elif Input.is_action_pressed("summon"):
		summon_flier()
	#elif not Input.is_action_pressed("test_alt"):
	#	selection_node.input(event)

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
			Global.arena.visible_mobs += [mob] # hacky but it works
	
func command_follow():
	for mob in Global.arena.visible_mobs:
		if is_instance_valid(mob) and mob not in followers: # mob could have died
			followers += [mob]
			mob.follow_mode(self)

func zombies_agg():
	#command_dispatch() # we must make them unremember to follow lich
	var result = get_mouse_target_pos()
	if not result:
		return
	for mob in followers:
		if is_instance_valid(mob):
			mob.aggressive_move(result.position)
	followers = []

func zombies_pass():
	var result = get_mouse_target_pos()
	if not result:
		return
	for mob in Global.arena.visible_mobs:
		if is_instance_valid(mob):
			# mob.passive_move(result.position)
			mob.passive_move(position)

func take_damage(damage: int):
	damage -= defense
	if damage > 0:
		hp -= damage
		healthChanged.emit()
	if hp <= 0 and death_timer.is_stopped():
		Global.arena.lose()
		death_timer.start()

func summon_flier():
	var sacrifice = []
	for f in followers:
		if is_instance_valid(f) and f is Doot:
			sacrifice += [f]
		if len(sacrifice) == 3:
			var pos = sacrifice[0].position
			for s in sacrifice:
				followers.erase(s)
				s.queue_free()
			var flyer_instance = flyer.instantiate()
			Global.arena.add_child(flyer_instance)
			flyer_instance.position = pos
			followers += [flyer_instance]
			flyer_instance.follow_mode(self)

func update_state():
	if hp <= 0:
		state = State.DEAD
	elif velocity != Vector3.ZERO:
		state = State.WALK
	elif velocity == Vector3.ZERO:
		if attacking:
			state = State.ATK
		else:
			state = State.IDLE

func update_animation_parameters():
	if state == State.IDLE:
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/move"] = false
		anim_tree["parameters/conditions/action"] = false
		anim_tree["parameters/conditions/attack1"] = false
		anim_tree["parameters/conditions/attack2"] = false
		anim_tree["parameters/conditions/attack3"] = false
	elif state == State.WALK:
		anim_tree["parameters/conditions/idle"] = false
		anim_tree["parameters/conditions/move"] = true
		anim_tree["parameters/conditions/action"] = false
		anim_tree["parameters/conditions/attack1"] = false
		anim_tree["parameters/conditions/attack2"] = false
		anim_tree["parameters/conditions/attack3"] = false
	elif state == State.ATK:
		if atk_pattern == 0:
			anim_tree["parameters/conditions/attack1"] = true
		elif atk_pattern == 1:
			anim_tree["parameters/conditions/attack2"] = true
		elif atk_pattern == 2:
			anim_tree["parameters/conditions/attack3"] = true
		else:
			anim_tree["parameters/conditions/action"] = true
		anim_tree["parameters/conditions/idle"] = true
		anim_tree["parameters/conditions/move"] = false
	elif state == State.DEAD:
		anim_tree["parameters/conditions/death"] = true
	
func _on_death_timer_timeout():
	queue_free()

func _on_cooldown_timeout():
	attacking = false

func _on_timer_timeout():
	if atk_pattern == 0:
		attack1()
	elif atk_pattern == 1:
		attack2()
	else:
		attack3()
