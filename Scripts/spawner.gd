extends Node3D

@export var max_civilians: int = 1
@export var max_knights: int = 0
@export var max_paladins: int = 0
@export var civilian_prefab: PackedScene
@export var knight_prefab: PackedScene
@export var paladin_prefab: PackedScene
@export var spawn_direction: Vector3 = Vector3(1,0,0)

var current_paladins: int = 0
var current_knights: int = 0
var current_civilians: int = 0
var last_spawned_entity = null

@export var hp = 30
var my_id
var process_tick_curr #unused
var process_tick_max #unused

func _on_ready():
	await Engine.get_main_loop().physics_frame
	my_id = Global.arena.enemy_spawned(self)
	while current_paladins < max_paladins:
		spawn_something_ready(paladin_prefab.instantiate())
		current_paladins += 1
	while current_knights < max_knights:
		spawn_something_ready(knight_prefab.instantiate())
		current_knights += 1
	while current_civilians < max_civilians:
		spawn_something_ready(civilian_prefab.instantiate())
		current_civilians += 1

func spawn_something():
	if current_paladins < max_paladins:
		last_spawned_entity = paladin_prefab.instantiate()
		current_paladins += 1
	elif current_knights < max_knights:
		last_spawned_entity = knight_prefab.instantiate()
		current_knights += 1
	elif current_civilians < max_civilians:
		last_spawned_entity = civilian_prefab.instantiate()
		current_civilians += 1
	else:
		last_spawned_entity = null
		return
	last_spawned_entity.velocity = spawn_direction
	last_spawned_entity.parent_spawner = self
	last_spawned_entity.global_position = $SpawnPoint.global_position
	last_spawned_entity.get_node("CollisionShape3D").disabled = true
	last_spawned_entity.ready_after_spawn = false
	Global.arena.add_child(last_spawned_entity)

func spawn_something_ready(entity: Node):
	var spawn_point: Vector3 = $ReadySpawnPoint.global_position
	spawn_point[0] += randf_range(-2,2)
	spawn_point[2] -= (current_paladins + current_knights + current_civilians)*2
	entity.position = spawn_point
	entity.velocity = Vector3(randf_range(-2,2), 0, randf_range(-2,2))
	entity.parent_spawner = self
	Global.arena.add_child(entity)

func _on_after_spawn_timer_timeout():
	if last_spawned_entity != null:
		last_spawned_entity.ready_after_spawn = true
		last_spawned_entity.get_node("CollisionShape3D").disabled = false

func take_damage(dmg: int):
	hp -= dmg
	if hp <= 0:
		queue_free()

func _on_spawn_timer_timeout():
	spawn_something()
	$AfterSpawnTimer.start()

func _on_tree_exited():
	Global.arena.enemy_despawned(my_id)
