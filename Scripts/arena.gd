extends Node

@export var win_screen_prefab: PackedScene
@export var lose_screen_prefab: PackedScene
@export var esc_screen_prefab: PackedScene

var game_over: bool = false
var enemy_count = 0

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

func enemy_despawned():
	enemy_count -= 1
	if enemy_count == 0:
		win()

func _on_tree_entered():
	Global.arena = self
