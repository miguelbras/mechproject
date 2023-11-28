extends Node

@export var win_screen_prefab: PackedScene
@export var lose_screen_prefab: PackedScene
@export var esc_screen_prefab: PackedScene

var game_over: bool = false
var building_count = 0
var process_tick_curr = 0
var enemy_id = 0
var enemy_map = {}
var ally_id = 1
var LICH_ID = 0
var ally_map = {}

var start_time: int

func _ready():
	start_time = Time.get_ticks_msec()/1000

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

func enemy_spawned(enemy: Node3D, building: bool) -> int:
	if building:
		building_count += 1
	enemy.process_tick_curr = process_tick_curr % enemy.process_tick_max
	process_tick_curr += 1
	enemy_id += 1
	enemy_map[enemy_id] = enemy
	return enemy_id

func enemy_despawned(id: int, building: bool):
	enemy_map.erase(id)
	if building:
		building_count -= 1
	if building_count == 0:
		win()
		
func lich_spawned(lich: Node3D):
	ally_map[LICH_ID] = lich

func ally_spawned(ally: Node3D) -> int:
	ally.process_tick_curr = process_tick_curr % ally.process_tick_max
	process_tick_curr += 1
	ally_id += 1
	ally_map[ally_id] = ally
	ally_map[LICH_ID].joined_horde(ally)
	return ally_id

func ally_despawned(id: int):
	ally_map.erase(id)
	
func _on_tree_entered():
	Global.arena = self
