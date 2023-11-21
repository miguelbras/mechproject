extends CharacterBody3D

@export var hp = 10
@export var max_velocity = 3

@onready var rot = $RotPoint
@onready var rot_timer = $RotPoint/Timer
@onready var cooldown = $RotPoint/Timer
@onready var sword = $RotPoint/SwordArea3D
@onready var cast = $ShapeCast3D

@onready var slow_timer = $SlowTimer
var slow_factor = 0.5
var slow = false
@export var attack1_debuff_prefab : PackedScene
var attack1_debuff = null

@onready var dot_timer = $DotTimer
var dot_tick_count_max = 5
var dot_ticks_left = 0
var dot_dmg = 1
@export var attack2_debuff_prefab : PackedScene
var attack2_debuff = null

var stop_dist = 1.5
var slashing = false
var can_attack = false
var base_rot
var mob_target

var ready_after_spawn = false
var parent_spawner = null

# Called when the node enters the scene tree for the first time.
func _ready():
	sword.set_process(false)
	base_rot = rot.basis

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if Input.is_action_pressed("attack1"):
	#	attack()
	if slashing:
		rot.rotate_y(20 * delta)

func attack():
	if not slashing:
		sword.set_process(true)
		slashing = true
		can_attack = false
		rot_timer.start()

func _on_timer_timeout():
	sword.set_process(false)
	slashing = false
	rot_timer.stop()
	rot.basis = base_rot

func take_damage(dmg: int):
	hp -= dmg
	if hp <= 0:
		queue_free()

func _physics_process(delta):
	if not slashing:
		follow_enemy()
	# update_state()
	# update_animation_parameters()
	look_at_target()
	if slow:
		velocity *= slow_factor
	move_and_slide()

func follow_enemy():
	mob_target = Util.get_closest_target(mob_target, position, cast, "Mob")
	if mob_target != null and mob_target.position.distance_to(position) > stop_dist:
		var desired_velocity = (mob_target.position - position) * max_velocity
		var steering = desired_velocity - velocity
		velocity = Util.truncate_vector(velocity + steering, max_velocity)
		velocity.y = 0
	else:
		velocity = Vector3.ZERO
		if can_attack:
			attack()

func look_at_target():
	if mob_target != null:
		self.look_at(mob_target.position, Vector3.UP, true)

func _on_cooldown_timeout():
	can_attack = mob_target != null

func set_slow():
	if slow:
		slow_timer.stop()
	slow = true
	slow_timer.start()
	if attack1_debuff == null:
		attack1_debuff = attack1_debuff_prefab.instantiate()
		add_child(attack1_debuff)

func _on_slow_timer_timeout():
	slow = false
	attack1_debuff.queue_free()
	attack1_debuff = null

func set_dot():
	if dot_ticks_left > 0:
		dot_timer.stop()
	dot_ticks_left = dot_tick_count_max
	dot_timer.start()
	if attack2_debuff == null:
		attack2_debuff = attack2_debuff_prefab.instantiate()
		add_child(attack2_debuff)

func _on_dot_timer_timeout():
	take_damage(dot_dmg)
	dot_ticks_left -= 1
	# print(dot_ticks_left)
	if dot_ticks_left == 0:
		dot_timer.stop()
		attack2_debuff.queue_free()
		attack2_debuff = null
