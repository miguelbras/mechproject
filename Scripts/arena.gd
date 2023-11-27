extends Node

@export var win_screen_prefab: PackedScene
@export var lose_screen_prefab: PackedScene
@export var esc_screen_prefab: PackedScene

var game_over: bool = false
var enemy_count = 0
var process_tick_curr = 0
var enemy_id = 0
var enemy_map = {}
var ally_id = 1
var LICH_ID = 0
var ally_map = {}

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

func enemy_spawned(enemy: Node3D) -> int:
	enemy_count += 1
	enemy.process_tick_curr = process_tick_curr % enemy.process_tick_max
	process_tick_curr += 1
	enemy_id += 1
	enemy_map[enemy_id] = enemy
	return enemy_id

func enemy_despawned(id: int):
	enemy_count -= 1
	enemy_map.erase(id)
	if enemy_count == 0:
		win()
		
func lich_spawned(lich: Node3D):
	ally_map[LICH_ID] = lich

func ally_spawned(ally: Node3D) -> int:
	ally.process_tick_curr = process_tick_curr % ally.process_tick_max
	process_tick_curr += 1
	ally_id += 1
	ally_map[ally_id] = ally
	return ally_id

func ally_despawned(id: int):
	ally_map.erase(id)
	
func _on_tree_entered():
	Global.arena = self
