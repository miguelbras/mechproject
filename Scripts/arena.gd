extends Node

@export var win_screen_prefab: PackedScene
@export var lose_screen_prefab: PackedScene
@export var esc_screen_prefab: PackedScene

var game_over: bool = false
var enemy_count = 0
var process_tick_curr = 0
var process_tick_max = 10
var enemy_id = 0
var enemy_map = {}
#var enemy_mutex = Mutex.new()
var ally_id = 1
var LICH_ID = 0
var ally_map = {}
#var ally_mutex = Mutex.new()

func win():
	if game_over:
		return
	game_over = true
	var win_screen = win_screen_prefab.instantiate()
	add_child(win_screen)
	
func lose():
	if game_over:
		return
	game_over = true
	var lose_screen = lose_screen_prefab.instantiate()
	add_child(lose_screen)

func enemy_spawned():
	enemy_count += 1
	
func enemy_spawned_light(enemy: Node3D) -> int:
	enemy_count += 1
	enemy.process_tick_curr = process_tick_curr
	enemy.process_tick_max = process_tick_max
	enemy_id += 1
	#enemy_mutex.lock()
	enemy_map[enemy_id] = enemy
	#enemy_mutex.unlock()
	process_tick_curr = (process_tick_curr + 1) % process_tick_max
	return enemy_id

func enemy_despawned():
	enemy_count -= 1
	if enemy_count == 0:
		win()

func enemy_despawned_light(id: int):
	enemy_count -= 1
	#enemy_mutex.lock()
	enemy_map.erase(id)
	#enemy_mutex.unlock()
	if enemy_count == 0:
		win()
		
func lich_spawned(lich: Node3D):
	#ally_mutex.lock()
	ally_map[LICH_ID] = lich
	#ally_mutex.unlock()

func ally_spawned_light(ally: Node3D) -> int:
	ally.process_tick_curr = process_tick_curr
	ally.process_tick_max = process_tick_max
	ally_id += 1
	#ally_mutex.lock()
	ally_map[ally_id] = ally
	#ally_mutex.unlock()
	process_tick_curr = (process_tick_curr + 1) % process_tick_max
	return ally_id
	
func ally_despawned_light(id: int):
	#ally_mutex.lock()
	ally_map.erase(id)
	#ally_mutex.unlock()

func _on_tree_entered():
	Global.arena = self
