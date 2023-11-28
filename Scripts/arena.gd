extends Node

class_name Arena

@export var win_screen_prefab: PackedScene
@export var lose_screen_prefab: PackedScene
@export var esc_screen_prefab: PackedScene

signal villagerCreated
signal villagerKilled
signal soldierCreated
signal soldierKilled
signal buildingCreated
signal buildingKilled
signal skeletonKilled
signal skeletonCreated
signal flyerCreated
signal flyerKilled


var game_over: bool = false
var enemy_count = 0
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

func enemy_spawned(enemy: Node3D) -> int:
	enemy_count += 1
	enemy.process_tick_curr = process_tick_curr % enemy.process_tick_max
	process_tick_curr += 1
	enemy_id += 1
	enemy_map[enemy_id] = enemy
	if enemy is Civilian:
		villagerCreated.emit()
	if enemy is Knight or enemy is Paladin:
		soldierCreated.emit()
	if enemy is Building:
		buildingCreated.emit()
	return enemy_id

func enemy_despawned(id: int):
	enemy_count -= 1
	var enemy = enemy_map[id]
	if enemy is Civilian:
		villagerKilled.emit()
	if enemy is Knight or enemy is Paladin:
		soldierKilled.emit()
	if enemy is Building:
		buildingKilled.emit()
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
	ally_map[LICH_ID].joined_horde(ally)
	if ally is Doot:
		skeletonCreated.emit()
	if ally is Flyer:
		flyerCreated.emit()
	return ally_id

func ally_despawned(id: int):
	var ally = ally_map[id]
	if ally is Doot:
		skeletonKilled.emit()
	if ally is Flyer:
		flyerKilled.emit()
	ally_map.erase(id)
	
func _on_tree_entered():
	Global.arena = self
