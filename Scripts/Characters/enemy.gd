extends CharacterBody3D

class_name Enemy

@export var hp = 10
@export var max_velocity = 3

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

var ready_after_spawn = true
var parent_spawner = null

func set_slow():
	if slow:
		slow_timer.stop()
	slow = true
	slow_timer.start()
	if attack1_debuff == null:
		attack1_debuff = attack1_debuff_prefab.instantiate()
		add_child(attack1_debuff)

func set_dot():
	if dot_ticks_left > 0:
		dot_timer.stop()
	dot_ticks_left = dot_tick_count_max
	dot_timer.start()
	if attack2_debuff == null:
		attack2_debuff = attack2_debuff_prefab.instantiate()
		add_child(attack2_debuff)

func take_damage(dmg: int):
	hp -= dmg
	if hp <= 0:
		queue_free()