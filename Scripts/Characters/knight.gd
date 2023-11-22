extends Enemy

@onready var rot = $RotPoint
@onready var rot_timer = $RotPoint/Timer
@onready var cooldown = $RotPoint/Timer
@onready var sword = $RotPoint/SwordArea3D
@onready var cast = $ShapeCast3D

var stop_dist = 1.5
var slashing = false
var can_attack = false
var base_rot
var mob_target

func _ready():
	Global.arena.enemy_spawned()
	sword.set_process(false)
	base_rot = rot.basis

func _process(delta):
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

func _physics_process(delta):
	if ready_after_spawn:
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

func _on_slow_timer_timeout():
	slow = false
	attack1_debuff.queue_free()
	attack1_debuff = null

func _on_dot_timer_timeout():
	take_damage(dot_dmg)
	dot_ticks_left -= 1
	# print(dot_ticks_left)
	if dot_ticks_left == 0:
		dot_timer.stop()
		attack2_debuff.queue_free()
		attack2_debuff = null

func _on_tree_exited():
	#var doot_instance = doot.instantiate()
	#Global.arena.add_child(doot_instance)
	#doot_instance.position = self.position # TODO
	Global.arena.enemy_despawned()
	if parent_spawner != null:
		parent_spawner.current_knights -= 1

