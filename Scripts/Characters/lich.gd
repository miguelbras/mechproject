extends CharacterBody3D

class_name Lich

enum State {IDLE, WALK, ATK, DEAD}

signal healthChanged
signal abilityUsed
signal abilityQUsed
signal abilityWUsed
signal abilityEUsed
signal abilityRUsed

@export var attack1_prefab : PackedScene
@export var attack2_prefab : PackedScene
@export var attack3_prefab : PackedScene
@export var escape_menu_prefab : PackedScene
@export var iso_camera: Camera3D
@export var top_down_camera: Camera3D
@export var aggressive_marker: Node3D
@export var my_speed = 6
@export var attack_cooldown_ms = 1000
@export var maxHp = 30
@export var defense = 0
@export var attackQ_Cooldown_ms = 1500
@export var attackW_Cooldown_ms = 2000
@export var attackE_Cooldown_ms = 2500
@export var flyer_summon_sacrifices = 5

@onready var navigationAgent : NavigationAgent3D = $NavigationAgent3D
@onready var iso_camera_delta: Vector3 = iso_camera.position - self.position
@onready var top_down_camera_delta_fixed: Vector3 = top_down_camera.position - self.position
@onready var top_down_camera_delta: Vector3 = top_down_camera.position - self.position
@onready var projectile_spawner : Node3D = $ProjectileSpawner
@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer
@onready var anim_tree = $AnimationTree
@onready var death_timer = $DeathTimer
@onready var global_cooldown = $Cooldown
@onready var follow_selection_marker = $SelectionMarker

const atk3_sound = preload("res://Sound/Attack/Eldritch Blast.wav")
const atk2_sound = preload("res://Sound/Attack/fire-magic-6947.mp3")
const atk1_sound = preload("res://Sound/Attack/magic-spell-6005.mp3")
const flyer = preload("res://Prefabs/Characters/flyer.tscn")

var hp = maxHp
var last_time_attackedQ = 0
var last_time_attackedW = 0
var last_time_attackedE = 0
var state = State.IDLE # animation state
var atk_pattern = 0
var attacking = false
var top_down_cam_zoom_level = 1
var escape_menu = null

func _ready():
	Global.arena.lich_spawned(self)
	anim_tree.active = true
	follow_selection_marker.visible = false
	# set initial aggression point as start pos
	aggressive_marker.position = self.position
	aggressive_marker.position.y = -0.1

func _process(delta):
	update_state()
	update_animation_parameters()
	if(navigationAgent.is_navigation_finished()):
		velocity = Vector3.ZERO
		return
	moveToPoint(delta, my_speed)
	iso_camera.position = self.position + iso_camera_delta
	top_down_camera.position = self.position + top_down_camera_delta

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
	if event.is_action_pressed("escape"):
		if escape_menu and is_instance_valid(escape_menu):
			escape_menu.queue_free()
		else:
			escape_menu = escape_menu_prefab.instantiate()
			Global.arena.add_child(escape_menu)
	if escape_menu and is_instance_valid(escape_menu):
		return
	# move inputs
	if Input.is_action_pressed("mouse_move"):
		mouse_move()
	# attack inputs
	if event.is_action_pressed("zombie_move"):
		if not attacking:
			atk_pattern = 3
			attacking = true
			global_cooldown.start()
		zombies_agg()
	elif event.is_action_pressed("zombie_follow"):
		if not attacking:
			atk_pattern = 3
			attacking = true
			global_cooldown.start()
		command_follow()
	elif event.is_action_pressed("attack1"):
		attack1()
	elif event.is_action_pressed("attack2"):
		attack2()
	elif event.is_action_pressed("attack3"):
		attack3()
	elif event.is_action_pressed("summon"):
		summon_flier()
	# camera inputs
	if event.is_action_pressed("zoom_out"):
		top_down_cam_zoom_level = min(top_down_cam_zoom_level*2, 8)
		top_down_camera_delta = top_down_camera_delta_fixed * top_down_cam_zoom_level
		top_down_camera.position = self.position + top_down_camera_delta
	elif event.is_action_pressed("zoom_in"):
		top_down_cam_zoom_level = max(top_down_cam_zoom_level/2, 1)
		top_down_camera_delta = top_down_camera_delta_fixed * top_down_cam_zoom_level
		top_down_camera.position = self.position + top_down_camera_delta
	elif event.is_action_pressed("switch_cam"):
		top_down_camera.current = iso_camera.current
		iso_camera.current = !top_down_camera.current

func joined_horde(mob):
	if follow_selection_marker.visible: # following lich
		mob.follow_mode(self)
	elif aggressive_marker.position.y > 0:
		mob.aggressive_move(aggressive_marker.position)
		

func get_mouse_target_pos():
	var mousePos = get_viewport().get_mouse_position()
	var rayLength = 500
	var cam = iso_camera if iso_camera.current else top_down_camera
	var from = cam.project_ray_origin(mousePos)
	var to = from + cam.project_ray_normal(mousePos) * rayLength
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
	
func attack1():
	if attacking or last_time_attackedQ + attackQ_Cooldown_ms > Time.get_ticks_msec():
		return
	atk_pattern = 0
	attacking = true
	global_cooldown.start()
	audio_player.stream = atk1_sound
	audio_player.play()
	attack(attack1_prefab.instantiate())
	last_time_attackedQ = Time.get_ticks_msec()
	abilityUsed.emit()
	abilityQUsed.emit()

func attack2():
	if attacking or last_time_attackedW + attackW_Cooldown_ms > Time.get_ticks_msec():
		return
	atk_pattern = 1
	attacking = true
	global_cooldown.start()
	audio_player.stream = atk2_sound
	audio_player.play()
	attack(attack2_prefab.instantiate())
	last_time_attackedW = Time.get_ticks_msec()
	abilityUsed.emit()
	abilityWUsed.emit()

func attack3():
	if attacking or last_time_attackedE + attackE_Cooldown_ms > Time.get_ticks_msec():
		return
	atk_pattern = 2
	attacking = true
	global_cooldown.start()
	audio_player.stream = atk3_sound
	audio_player.play()
	attack(attack3_prefab.instantiate())
	last_time_attackedE = Time.get_ticks_msec()
	abilityUsed.emit()
	abilityEUsed.emit()

func command_follow():
	for mob in Global.arena.ally_map.values():
		if mob is Lich:
			continue
		if is_instance_valid(mob):
			mob.follow_mode(self)
	aggressive_marker.position = Vector3(0, -5, 0) # hide under map
	follow_selection_marker.visible = true

func zombies_agg():
	var result = get_mouse_target_pos()
	if not result:
		return
	for mob in Global.arena.ally_map.values():
		if mob is Lich:
			continue
		if is_instance_valid(mob):
			mob.aggressive_move(result.position)
	aggressive_marker.position = result.position
	aggressive_marker.position.y += 0.1
	follow_selection_marker.visible = false

func take_damage(damage: int):
	damage -= defense
	if damage > 0:
		hp -= damage
		healthChanged.emit()
	if hp <= 0 and death_timer.is_stopped():
		Global.arena.lose()
		death_timer.start()

func summon_flier():
	var result = get_mouse_target_pos()
	if not result:
		return
	var sacrifice = []
	for f in Global.arena.ally_map.values():
		if is_instance_valid(f) and f is Doot:
			sacrifice += [f]
		if len(sacrifice) == flyer_summon_sacrifices:
			for s in sacrifice:
				s.queue_free()
			var flyer_instance = flyer.instantiate()
			Global.arena.add_child(flyer_instance)
			flyer_instance.position = result.position
			flyer_instance.follow_mode(self)
			abilityRUsed.emit()
			return

func update_state():
	if hp <= 0:
		state = State.DEAD
	elif attacking:
		state = State.ATK
	elif velocity != Vector3.ZERO:
		state = State.WALK
	else:
		state = State.IDLE

func update_animation_parameters():
	anim_tree["parameters/conditions/idle"] = state == State.IDLE or state == State.ATK
	anim_tree["parameters/conditions/move"] = state == State.WALK
	anim_tree["parameters/conditions/attack1"] = state == State.ATK and atk_pattern == 0
	anim_tree["parameters/conditions/attack2"] = state == State.ATK and atk_pattern == 1
	anim_tree["parameters/conditions/attack3"] = state == State.ATK and atk_pattern == 2
	anim_tree["parameters/conditions/action"] = state == State.ATK and atk_pattern == 3
	anim_tree["parameters/conditions/death"] = state == State.DEAD

func _on_death_timer_timeout():
	queue_free()

func _on_cooldown_timeout():
	attacking = false
