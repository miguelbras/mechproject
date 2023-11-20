extends Node

var game_over: bool = false
var enemy_count = 0
@export var win_screen_prefab: PackedScene
@export var lose_screen_prefab: PackedScene
@export var esc_screen_prefab: PackedScene


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func win():
	game_over = true
	var win_screen = win_screen_prefab.instantiate()
	self.add_child(win_screen)
	
func lose():
	game_over = true
	var lose_screen = lose_screen_prefab.instantiate()
	self.add_child(lose_screen)

func enemy_spawned():
	enemy_count += 1

func enemy_despawned():
	enemy_count -= 1
	if enemy_count == 0:
		win()


func _on_tree_entered():
	Global.arena = self
